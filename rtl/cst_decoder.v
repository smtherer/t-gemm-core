`timescale 1ns / 1ps

module cst_decoder (
    input  wire [63:0]  nz_mask,
    input  wire [63:0]  sign_stream,
    output reg  [127:0] weights_128b
);
    integer i;
    integer ptr;

    always @(*) begin
        ptr = 0;
        weights_128b = 128'd0;
        for (i = 0; i < 64; i = i + 1) begin
            if (nz_mask[i]) begin
                if (sign_stream[ptr])
                    weights_128b[2*i +: 2] = 2'b10; // -1
                else
                    weights_128b[2*i +: 2] = 2'b01; // +1
                ptr = ptr + 1;
            end else begin
                weights_128b[2*i +: 2] = 2'b00;     // 0
            end
        end
    end
endmodule
