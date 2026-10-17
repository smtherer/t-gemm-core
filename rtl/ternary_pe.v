`timescale 1ns / 1ps

module ternary_pe (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [1:0]  weight_in,
    input  wire signed [7:0]  act_in,
    input  wire signed [31:0] acc_in,
    output reg  signed [7:0]  act_out,
    output reg  signed [31:0] acc_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            act_out <= 8'sd0;
            acc_out <= 32'sd0;
        end else begin
            act_out <= act_in;
            case (weight_in)
                2'b01:   acc_out <= acc_in + {{24{act_in[7]}}, act_in};
                2'b10:   acc_out <= acc_in - {{24{act_in[7]}}, act_in};
                default: acc_out <= acc_in;
            endcase
        end
    end
endmodule
