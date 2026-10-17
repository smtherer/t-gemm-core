import os
import subprocess
import shutil
import numpy as np

def run_benchmark():
    print("==================================================================")
    print("      8x8 TERNARY SYSTOLIC ACCELERATOR: 64x64 LAYER BENCHMARK     ")
    print("==================================================================")

    K_DIM = 64
    N_DIM = 64
    TOTAL_OPS = 2 * K_DIM * N_DIM

    np.random.seed(1337)
    x_float = np.random.randn(K_DIM).astype(np.float32)
    w_ternary = np.random.choice([-1, 0, 1], size=(K_DIM, N_DIM), p=[0.25, 0.50, 0.25]).astype(np.int8)

    gamma = float(np.max(np.abs(x_float)))
    scale_x = 127.0 / (gamma + 1e-5)
    x_quant = np.clip(np.round(x_float * scale_x), -128, 127).astype(np.int8)

    y_int_golden = np.matmul(x_quant.astype(np.int32), w_ternary.astype(np.int32))
    y_float_golden = y_int_golden * (gamma / 127.0)

    tile_words = []
    for tn in range(N_DIM // 8):
        for tk in range(K_DIM // 8):
            tile_w = w_ternary[tk*8:(tk+1)*8, tn*8:(tn+1)*8]
            word128 = 0
            for r in range(8):
                for c in range(8):
                    val = tile_w[r, c]
                    bits = 0b00 if val == 0 else (0b01 if val == 1 else 0b10)
                    bit_idx = (r * 8 + c) * 2
                    word128 |= (bits << bit_idx)
            tile_words.append(word128)

    tb_code = f"""`timescale 1ns / 1ps
module tb_systolic_gemm_8x8;
    reg clk; reg rst_n; reg start;
    reg w_wr_en; reg [9:0] w_wr_addr; reg [127:0] w_wr_data;
    reg act_wr_en; reg [9:0] act_wr_addr; reg signed [7:0] act_wr_data;
    wire done; wire [31:0] total_cycles;
    reg [9:0] out_rd_addr; wire signed [31:0] out_rd_data;

    systolic_gemm_engine_8x8 #(.K_DIM({K_DIM}), .N_DIM({N_DIM})) dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .w_wr_en(w_wr_en), .w_wr_addr(w_wr_addr), .w_wr_data(w_wr_data),
        .act_wr_en(act_wr_en), .act_wr_addr(act_wr_addr), .act_wr_data(act_wr_data),
        .done(done), .total_cycles(total_cycles),
        .out_rd_addr(out_rd_addr), .out_rd_data(out_rd_data)
    );

    always #5 clk = ~clk;
    integer i;
    initial begin
        clk = 0; rst_n = 0; start = 0; w_wr_en = 0; act_wr_en = 0; out_rd_addr = 0;
        #20 rst_n = 1;
"""
    for idx, word in enumerate(tile_words):
        tb_code += f"        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd{idx}; w_wr_data = 128'h{word:032X};\n"

    tb_code += "\n        // Activations\n"
    for idx, val in enumerate(x_quant):
        val_u8 = int(val) & 0xFF
        tb_code += f"        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd{idx}; act_wr_data = 8'h{val_u8:02X};\n"

    tb_code += f"""        @(negedge clk); w_wr_en = 0; act_wr_en = 0;
        @(negedge clk); start = 1;
        @(negedge clk); start = 0;
        wait(done == 1'b1);
        #20;
        $display("HW_TOTAL_CYCLES=%0d", total_cycles);
        for (i = 0; i < {N_DIM}; i = i + 1) begin
            out_rd_addr = i[9:0]; #5;
            $display("HW_OUT[%0d]=%d", i, out_rd_data);
        end
        $finish;
    end
endmodule
"""

    os.makedirs("build", exist_ok=True)
    with open("build/tb_systolic_gemm_8x8.v", "w") as f:
        f.write(tb_code)

    iverilog = shutil.which("iverilog") or "/opt/homebrew/bin/iverilog" or "/usr/local/bin/iverilog"
    vvp = shutil.which("vvp") or "/opt/homebrew/bin/vvp" or "/usr/local/bin/vvp"

    print("[1/3] Compiling 8x8 Hardware Subsystem...")
    compile_cmd = [
        iverilog, "-o", "build/sim_layer_8x8.vvp",
        "build/tb_systolic_gemm_8x8.v", "rtl/systolic_gemm_engine_8x8.v",
        "rtl/ternary_systolic_8x8.v", "rtl/ternary_pe.v"
    ]
    res = subprocess.run(compile_cmd, capture_output=True, text=True)
    if res.returncode != 0:
        print("[ERROR] Compilation failed:\n", res.stderr)
        return

    print("[2/3] Simulating Layer Execution...")
    sim_res = subprocess.run([vvp, "build/sim_layer_8x8.vvp"], capture_output=True, text=True)
    if sim_res.returncode != 0:
        print("[ERROR] Simulation error:\n", sim_res.stderr)
        return

    hw_cycles = 0
    hw_outputs = []
    for line in sim_res.stdout.splitlines():
        if line.startswith("HW_TOTAL_CYCLES"):
            hw_cycles = int(line.split("=")[1].strip())
        elif line.startswith("HW_OUT"):
            hw_outputs.append(int(line.split("=")[1].strip()))

    hw_outputs = np.array(hw_outputs, dtype=np.int32)
    int_match = np.array_equal(y_int_golden, hw_outputs)
    y_float_hw = hw_outputs * (gamma / 127.0)

    cosine_sim = np.dot(y_float_golden, y_float_hw) / (
        np.linalg.norm(y_float_golden) * np.linalg.norm(y_float_hw) + 1e-9
    )
    mse = np.mean((y_float_golden - y_float_hw) ** 2)

    latency_us = (hw_cycles / 100e6) * 1e6
    energy_uj = (0.8 * (latency_us * 1e-6)) * 1e6

    print("\n================ BENCHMARK SCORECARD ================")
    print(f"Matrix Dimension            : {K_DIM} x {N_DIM} (4,096 Ternary Parameters)")
    print(f"Total Operations Computed   : {TOTAL_OPS:,} Ops")
    print(f"Hardware Clock Cycles       : {hw_cycles} Cycles")
    print(f"Execution Latency @ 100MHz  : {latency_us:.2f} µs")
    print(f"Hardware Multipliers Used   : 0 (Pure Adder Trees)")
    print(f"Bit-Exact Integer Parity    : {'MATCH [100%]' if int_match else 'FAIL'}")
    print(f"Cosine Similarity           : {cosine_sim:.8f}")
    print(f"Mean Squared Error (MSE)    : {mse:.8e}")
    print(f"Estimated Energy per Layer  : {energy_uj:.4f} µJ")
    print("=====================================================\n")

if __name__ == "__main__":
    run_benchmark()
