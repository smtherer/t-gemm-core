`timescale 1ns / 1ps

module t_gemm_top #(
    parameter ACT_WIDTH = 8,
    parameter ACC_WIDTH = 16,
    parameter N         = 4
)(
    input  wire                          clk,
    input  wire                          rst_n,
    input  wire                          load_weights,
    input  wire [(N*2)-1:0]              weight_in_bus,
    input  wire [(N*ACT_WIDTH)-1:0]      act_in_bus,
    output wire [(N*ACC_WIDTH)-1:0]      psum_out_bus
);

    // Grid wire matrices: [row][col]
    wire signed [ACT_WIDTH-1:0] act_net  [0:N-1][0:N];
    wire signed [ACC_WIDTH-1:0] psum_net [0:N][0:N-1];
    wire [1:0]                  w_net    [0:N][0:N-1];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : BIND_IO
            // Left boundary: activations enter
            assign act_net[i][0]  = act_in_bus[i*ACT_WIDTH +: ACT_WIDTH];
            // Top boundary: zero partial sums and input weights enter
            assign psum_net[0][i] = {ACC_WIDTH{1'b0}};
            assign w_net[0][i]    = weight_in_bus[i*2 +: 2];
            // Bottom boundary: completed GEMM outputs
            assign psum_out_bus[i*ACC_WIDTH +: ACC_WIDTH] = psum_net[N][i];
        end
    endgenerate

    // 4x4 Processing Element Grid
    genvar r, c;
    generate
        for (r = 0; r < N; r = r + 1) begin : ROW
            for (c = 0; c < N; c = c + 1) begin : COL
                t_pe #(
                    .ACT_WIDTH(ACT_WIDTH),
                    .ACC_WIDTH(ACC_WIDTH)
                ) pe_inst (
                    .clk(clk),
                    .rst_n(rst_n),
                    .load_weight(load_weights),
                    .weight_in(w_net[r][c]),
                    .weight_out(w_net[r+1][c]),
                    .act_in(act_net[r][c]),
                    .psum_in(psum_net[r][c]),
                    .act_out(act_net[r][c+1]),
                    .psum_out(psum_net[r+1][c])
                );
            end
        end
    endgenerate

endmodule
