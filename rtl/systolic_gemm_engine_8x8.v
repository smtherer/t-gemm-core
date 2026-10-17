`timescale 1ns / 1ps

module systolic_gemm_engine_8x8 #(
    parameter K_DIM = 64,
    parameter N_DIM = 64
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire        w_wr_en,
    input  wire [9:0]  w_wr_addr,
    input  wire [127:0] w_wr_data,
    input  wire        act_wr_en,
    input  wire [9:0]  act_wr_addr,
    input  wire signed [7:0] act_wr_data,
    output reg         done,
    output reg  [31:0] total_cycles,
    input  wire [9:0]  out_rd_addr,
    output wire signed [31:0] out_rd_data
);
    localparam TOTAL_TILES = (K_DIM / 8) * (N_DIM / 8);

    reg [127:0] weight_tiles [0:TOTAL_TILES-1];
    reg signed [7:0] act_buffer [0:K_DIM-1];
    reg signed [31:0] out_buffer [0:N_DIM-1];

    always @(posedge clk) begin
        if (w_wr_en) weight_tiles[w_wr_addr] <= w_wr_data;
        if (act_wr_en) act_buffer[act_wr_addr] <= act_wr_data;
    end
    assign out_rd_data = out_buffer[out_rd_addr];

    reg [6:0] feed_idx;
    reg feeding;
    wire [2:0] feed_k = feed_idx[2:0];

    reg core_valid_in;
    reg signed [7:0] in_a [0:7];
    reg [127:0] core_cfg_weights;
    wire core_valid_out;
    wire signed [31:0] out_r [0:7];

    ternary_systolic_8x8 core_mesh (
        .clk(clk), .rst_n(rst_n),
        .cfg_weights(core_cfg_weights),
        .valid_in(core_valid_in),
        .in_act_0(in_a[0]), .in_act_1(in_a[1]), .in_act_2(in_a[2]), .in_act_3(in_a[3]),
        .in_act_4(in_a[4]), .in_act_5(in_a[5]), .in_act_6(in_a[6]), .in_act_7(in_a[7]),
        .valid_out(core_valid_out),
        .out_res_0(out_r[0]), .out_res_1(out_r[1]), .out_res_2(out_r[2]), .out_res_3(out_r[3]),
        .out_res_4(out_r[4]), .out_res_5(out_r[5]), .out_res_6(out_r[6]), .out_res_7(out_r[7])
    );

    reg signed [31:0] acc_accum [0:7];
    reg [6:0] out_tile_idx;
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done <= 1'b0;
            total_cycles <= 32'd0;
            feeding <= 1'b0;
            feed_idx <= 7'd0;
            core_valid_in <= 1'b0;
            out_tile_idx <= 7'd0;
            for (i = 0; i < 8; i = i + 1) begin
                in_a[i] <= 8'sd0;
                acc_accum[i] <= 32'sd0;
            end
            for (i = 0; i < N_DIM; i = i + 1) out_buffer[i] <= 32'sd0;
        end else begin
            if (start) begin
                done <= 1'b0;
                total_cycles <= 32'd0;
                feeding <= 1'b1;
                feed_idx <= 7'd0;
                out_tile_idx <= 7'd0;
                for (i = 0; i < 8; i = i + 1) acc_accum[i] <= 32'sd0;
                for (i = 0; i < N_DIM; i = i + 1) out_buffer[i] <= 32'sd0;
            end

            if (feeding || !done) total_cycles <= total_cycles + 1;

            if (feeding) begin
                core_cfg_weights <= weight_tiles[feed_idx];
                core_valid_in <= 1'b1;
                for (i = 0; i < 8; i = i + 1) in_a[i] <= act_buffer[feed_k * 8 + i];
                if (feed_idx == TOTAL_TILES - 1) feeding <= 1'b0;
                else feed_idx <= feed_idx + 1;
            end else begin
                core_valid_in <= 1'b0;
            end

            if (core_valid_out) begin
                if (out_tile_idx[2:0] == 3'd7) begin
                    for (i = 0; i < 8; i = i + 1) begin
                        out_buffer[(out_tile_idx >> 3) * 8 + i] <= acc_accum[i] + out_r[i];
                        acc_accum[i] <= 32'sd0;
                    end
                end else begin
                    for (i = 0; i < 8; i = i + 1) acc_accum[i] <= acc_accum[i] + out_r[i];
                end

                if (out_tile_idx == TOTAL_TILES - 1) done <= 1'b1;
                else out_tile_idx <= out_tile_idx + 1;
            end
        end
    end
endmodule
