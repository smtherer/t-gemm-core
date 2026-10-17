`timescale 1ns / 1ps

module ternary_systolic_8x8 (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [127:0] cfg_weights,
    input  wire        valid_in,
    input  wire signed [7:0] in_act_0, in_act_1, in_act_2, in_act_3,
    input  wire signed [7:0] in_act_4, in_act_5, in_act_6, in_act_7,
    output wire        valid_out,
    output wire signed [31:0] out_res_0, out_res_1, out_res_2, out_res_3,
    output wire signed [31:0] out_res_4, out_res_5, out_res_6, out_res_7
);
    wire signed [7:0] in_act_array [0:7];
    assign in_act_array[0] = in_act_0; assign in_act_array[1] = in_act_1;
    assign in_act_array[2] = in_act_2; assign in_act_array[3] = in_act_3;
    assign in_act_array[4] = in_act_4; assign in_act_array[5] = in_act_5;
    assign in_act_array[6] = in_act_6; assign in_act_array[7] = in_act_7;

    wire signed [7:0]  skewed_act [0:7];
    assign skewed_act[0] = in_act_array[0];

    genvar r_idx;
    generate
        for (r_idx = 1; r_idx < 8; r_idx = r_idx + 1) begin : gen_input_skew
            reg signed [7:0] skew_pipe [0:r_idx-1];
            integer s;
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    for (s = 0; s < r_idx; s = s + 1) skew_pipe[s] <= 8'sd0;
                end else begin
                    skew_pipe[0] <= in_act_array[r_idx];
                    for (s = 1; s < r_idx; s = s + 1) skew_pipe[s] <= skew_pipe[s-1];
                end
            end
            assign skewed_act[r_idx] = skew_pipe[r_idx-1];
        end
    endgenerate

    wire [1:0] pe_weight [0:63];
    genvar r_w, c_w;
    generate
        for (r_w = 0; r_w < 8; r_w = r_w + 1) begin : gen_w_row
            for (c_w = 0; c_w < 8; c_w = c_w + 1) begin : gen_w_col
                localparam integer D = r_w + c_w;
                wire [1:0] raw_w = cfg_weights[((r_w * 8 + c_w) * 2) +: 2];
                if (D == 0) begin
                    assign pe_weight[r_w * 8 + c_w] = raw_w;
                end else begin
                    reg [1:0] w_pipe [0:D-1];
                    integer w_i;
                    always @(posedge clk or negedge rst_n) begin
                        if (!rst_n) begin
                            for (w_i = 0; w_i < D; w_i = w_i + 1) w_pipe[w_i] <= 2'b00;
                        end else begin
                            w_pipe[0] <= raw_w;
                            for (w_i = 1; w_i < D; w_i = w_i + 1) w_pipe[w_i] <= w_pipe[w_i-1];
                        end
                    end
                    assign pe_weight[r_w * 8 + c_w] = w_pipe[D-1];
                end
            end
        end
    endgenerate

    wire signed [7:0]  pe_act [0:71];
    wire signed [31:0] pe_acc [0:71];

    genvar r, c;
    generate
        for (r = 0; r < 8; r = r + 1) begin : gen_west_boundary
            assign pe_act[r * 9] = skewed_act[r];
        end
        for (c = 0; c < 8; c = c + 1) begin : gen_north_boundary
            assign pe_acc[c] = 32'sd0;
        end
        for (r = 0; r < 8; r = r + 1) begin : gen_row
            for (c = 0; c < 8; c = c + 1) begin : gen_col
                ternary_pe pe_inst (
                    .clk(clk),
                    .rst_n(rst_n),
                    .weight_in(pe_weight[r * 8 + c]),
                    .act_in(pe_act[r * 9 + c]),
                    .acc_in(pe_acc[r * 8 + c]),
                    .act_out(pe_act[r * 9 + c + 1]),
                    .acc_out(pe_acc[(r + 1) * 8 + c])
                );
            end
        end
    endgenerate

    wire signed [31:0] deskewed_res [0:7];
    genvar c_idx;
    generate
        for (c_idx = 0; c_idx < 8; c_idx = c_idx + 1) begin : gen_output_deskew
            localparam integer DELAY_STEPS = 7 - c_idx;
            if (DELAY_STEPS == 0) begin
                assign deskewed_res[c_idx] = pe_acc[64 + c_idx];
            end else begin
                reg signed [31:0] deskew_pipe [0:DELAY_STEPS-1];
                integer d;
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        for (d = 0; d < DELAY_STEPS; d = d + 1) deskew_pipe[d] <= 32'sd0;
                    end else begin
                        deskew_pipe[0] <= pe_acc[64 + c_idx];
                        for (d = 1; d < DELAY_STEPS; d = d + 1) deskew_pipe[d] <= deskew_pipe[d-1];
                    end
                end
                assign deskewed_res[c_idx] = deskew_pipe[DELAY_STEPS-1];
            end
        end
    endgenerate

    assign out_res_0 = deskewed_res[0]; assign out_res_1 = deskewed_res[1];
    assign out_res_2 = deskewed_res[2]; assign out_res_3 = deskewed_res[3];
    assign out_res_4 = deskewed_res[4]; assign out_res_5 = deskewed_res[5];
    assign out_res_6 = deskewed_res[6]; assign out_res_7 = deskewed_res[7];

    reg [14:0] valid_pipe;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) valid_pipe <= 15'b0;
        else valid_pipe <= {valid_pipe[13:0], valid_in};
    end
    assign valid_out = valid_pipe[14];
endmodule
