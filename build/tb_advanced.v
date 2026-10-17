`timescale 1ns / 1ps
module tb_advanced;
    reg clk; reg rst_n;
    reg [1:0] weight_in; reg signed [7:0] act_in; reg signed [31:0] acc_in;
    wire signed [7:0] act_out; wire signed [31:0] acc_out_gated;

    ternary_pe_gated uut_gated (
        .clk(clk), .rst_n(rst_n), .weight_in(weight_in),
        .act_in(act_in), .acc_in(acc_in),
        .act_out(act_out), .acc_out(acc_out_gated)
    );

    reg signed [31:0] csa_sum_in, csa_carry_in, csa_operand;
    wire signed [31:0] csa_sum_out, csa_carry_out;

    csa_accumulator_32b uut_csa (
        .acc_sum_in(csa_sum_in), .acc_carry_in(csa_carry_in), .operand_in(csa_operand),
        .acc_sum_out(csa_sum_out), .acc_carry_out(csa_carry_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst_n = 0; weight_in = 2'b00; act_in = 8'sd0; acc_in = 32'sd0;
        csa_sum_in = 32'sd0; csa_carry_in = 32'sd0; csa_operand = 32'sd0;
        #20 rst_n = 1;

        @(negedge clk); weight_in = 2'b01; act_in = 8'sd25; acc_in = 32'sd100;
        @(posedge clk); #1;
        $display("TEST_GATED_P1: Out=%0d Expected=125", acc_out_gated);

        @(negedge clk); weight_in = 2'b00; act_in = 8'sd99; acc_in = 32'sd125;
        @(posedge clk); #1;
        $display("TEST_GATED_ZERO: Out=%0d Expected=125", acc_out_gated);

        @(negedge clk); weight_in = 2'b10; act_in = 8'sd40; acc_in = 32'sd125;
        @(posedge clk); #1;
        $display("TEST_GATED_M1: Out=%0d Expected=85", acc_out_gated);

        csa_sum_in = 32'd50; csa_carry_in = 32'd30; csa_operand = 32'd25; #1;
        $display("TEST_CSA: SumOut+CarryOut=%0d Expected=105", (csa_sum_out + csa_carry_out));
        $finish;
    end
endmodule
