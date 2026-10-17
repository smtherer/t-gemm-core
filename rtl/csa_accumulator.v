`timescale 1ns / 1ps

module csa_accumulator_32b (
    input  wire signed [31:0] acc_sum_in,
    input  wire signed [31:0] acc_carry_in,
    input  wire signed [31:0] operand_in,
    output wire signed [31:0] acc_sum_out,
    output wire signed [31:0] acc_carry_out
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : gen_csa_bits
            assign acc_sum_out[i] = acc_sum_in[i] ^ acc_carry_in[i] ^ operand_in[i];
            if (i < 31) begin
                assign acc_carry_out[i+1] = (acc_sum_in[i] & acc_carry_in[i]) | 
                                            (acc_carry_in[i] & operand_in[i]) | 
                                            (acc_sum_in[i] & operand_in[i]);
            end
        end
    endgenerate
    assign acc_carry_out[0] = 1'b0;
endmodule
