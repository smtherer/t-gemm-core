`default_nettype none

module tt_um_tgemm (
    input  wire [7:0] ui_in,    // Dedicated inputs: Byte-wide data input
    output wire [7:0] uo_out,   // Dedicated outputs: Lower 8 bits of accumulator output
    input  wire [7:0] uio_in,   // IO inputs: [0]=load_weights, [1]=stream_act, [3:2]=col_sel
    output wire [7:0] uio_out,  // IO outputs: Upper 8 bits of accumulator output
    output wire [7:0] uio_oe,   // IO direction: 8'b1111_0000 (lower 4 inputs, upper 4 outputs)
    input  wire       ena,      // Tiny Tapeout design enable
    input  wire       clk,      // System clock
    input  wire       rst_n     // Active-low asynchronous reset
);

    // IO Pin Direction: lower 4 bits input, upper 4 bits output
    assign uio_oe = 8'b1111_0000;

    wire load_weights = uio_in[0];
    wire [1:0] col_sel = uio_in[3:2];

    // Internal Systolic Array Ports
    reg  [7:0]  weight_bus;
    reg  [31:0] act_bus;
    wire [63:0] psum_bus;

    // Byte-wide input multiplexing
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            weight_bus <= 8'd0;
            act_bus    <= 32'd0;
        end else if (ena) begin
            if (load_weights) begin
                weight_bus <= ui_in;
            end else begin
                // Shift byte stream into 32-bit activation lane
                act_bus <= {act_bus[23:0], ui_in};
            end
        end
    end

    // Core Systolic Fabric Instance
    t_gemm_top #(
        .ACT_WIDTH(8),
        .ACC_WIDTH(16),
        .N(4)
    ) core_inst (
        .clk(clk),
        .rst_n(rst_n),
        .load_weights(load_weights),
        .weight_in_bus(weight_bus),
        .act_in_bus(act_bus),
        .psum_out_bus(psum_bus)
    );

    // Multiplex selected 16-bit systolic column output to the 8-bit external pins
    wire [15:0] selected_col = (col_sel == 2'b00) ? psum_bus[15:0]  :
                               (col_sel == 2'b01) ? psum_bus[31:16] :
                               (col_sel == 2'b10) ? psum_bus[47:32] :
                                                    psum_bus[63:48];

    assign uo_out  = selected_col[7:0];      // Lower 8-bit output
    assign uio_out = {selected_col[15:8], 4'b0000}; // Upper 8-bit output on IO pins

endmodule
