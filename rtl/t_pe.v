`timescale 1ns / 1ps

module t_pe #(
    parameter ACT_WIDTH = 8,
    parameter ACC_WIDTH = 16
)(
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 load_weight,
    input  wire [1:0]           weight_in,
    output wire [1:0]           weight_out,
    input  wire signed [ACT_WIDTH-1:0] act_in,
    input  wire signed [ACC_WIDTH-1:0] psum_in,
    output reg  signed [ACT_WIDTH-1:0] act_out,
    output reg  signed [ACC_WIDTH-1:0] psum_out
);

    reg [1:0] weight_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            weight_reg <= 2'b00;
        else if (load_weight)
            weight_reg <= weight_in;
    end

    // Pass weight down to the next row during configuration
    assign weight_out = weight_reg;

    // Multiplierless ternary logic
    reg signed [ACC_WIDTH-1:0] term;
    always @(*) begin
        case (weight_reg)
            2'b01:   term = {{ (ACC_WIDTH-ACT_WIDTH){act_in[ACT_WIDTH-1]} }, act_in}; // +Act
            2'b10:   term = -{{ (ACC_WIDTH-ACT_WIDTH){act_in[ACT_WIDTH-1]} }, act_in}; // -Act
            default: term = {ACC_WIDTH{1'b0}};                                         // 0 (Bypass)
        endcase
    end

    // Systolic pipeline registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            act_out  <= {ACT_WIDTH{1'b0}};
            psum_out <= {ACC_WIDTH{1'b0}};
        end else begin
            act_out  <= act_in;
            psum_out <= psum_in + term;
        end
    end

endmodule
