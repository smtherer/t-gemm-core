`timescale 1ns / 1ps
module tb_systolic_gemm_8x8;
    reg clk; reg rst_n; reg start;
    reg w_wr_en; reg [9:0] w_wr_addr; reg [127:0] w_wr_data;
    reg act_wr_en; reg [9:0] act_wr_addr; reg signed [7:0] act_wr_data;
    wire done; wire [31:0] total_cycles;
    reg [9:0] out_rd_addr; wire signed [31:0] out_rd_data;

    systolic_gemm_engine_8x8 #(.K_DIM(64), .N_DIM(64)) dut (
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
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd0; w_wr_data = 128'h1820220450A486400041A80A40869181;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd1; w_wr_data = 128'h9804600020466881A02950004220A210;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd2; w_wr_data = 128'h841080AA649A00205141800250424148;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd3; w_wr_data = 128'h11225008411941808148948124601244;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd4; w_wr_data = 128'h0295484188A4114654120A0688241401;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd5; w_wr_data = 128'h445054521098148458001089989109A6;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd6; w_wr_data = 128'h2189085600522855189141A085292848;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd7; w_wr_data = 128'h52010A29414212916009404500200288;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd8; w_wr_data = 128'h608020625880048000812A2128012880;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd9; w_wr_data = 128'h50054288251645210468850A88152011;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd10; w_wr_data = 128'hA8429826002060491128044018164010;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd11; w_wr_data = 128'h8221A100108050946960A48909020800;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd12; w_wr_data = 128'h46845044222424068008064860188066;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd13; w_wr_data = 128'h65A464A0A04489AA122082269044A219;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd14; w_wr_data = 128'h0204820050100250081010082549A804;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd15; w_wr_data = 128'h8211A8902006081A6228800114258900;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd16; w_wr_data = 128'h826A124026050920491A0A1024000141;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd17; w_wr_data = 128'hA08015081012920008A4555521698804;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd18; w_wr_data = 128'h08004A81A551108156052946904A05A0;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd19; w_wr_data = 128'h88026A56142429229090000180902224;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd20; w_wr_data = 128'hA685062204865880000689240A812415;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd21; w_wr_data = 128'h8048011998A84102096A0458010804A8;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd22; w_wr_data = 128'hA8469011188591109406020020849061;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd23; w_wr_data = 128'h24552610200501A98004182006049292;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd24; w_wr_data = 128'h061161A0601654502025104010084608;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd25; w_wr_data = 128'h2064190A908406A8161001448A924660;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd26; w_wr_data = 128'h1A880006404800146501641020854820;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd27; w_wr_data = 128'h240A0009560601012428088401220861;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd28; w_wr_data = 128'hA060640922012462601600922424510A;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd29; w_wr_data = 128'h01095904246001404A24282016A084A4;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd30; w_wr_data = 128'h012481126591202A4241800022145990;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd31; w_wr_data = 128'h0024421146A4288246288A804A200424;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd32; w_wr_data = 128'h41468019404AA894000618242128428A;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd33; w_wr_data = 128'h80601910222202414000420124014250;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd34; w_wr_data = 128'h0540A4110A140514491460814208021A;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd35; w_wr_data = 128'h041A114145420A5049006698949512A5;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd36; w_wr_data = 128'h41602A50262024001010090060A00928;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd37; w_wr_data = 128'h4004A0520521080054810A8141810404;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd38; w_wr_data = 128'h666128640502109501A4148288968408;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd39; w_wr_data = 128'h25859A0422024441214A04500A100158;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd40; w_wr_data = 128'h0026084025926900A064500414028828;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd41; w_wr_data = 128'h0246895800A5455144A0121648212180;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd42; w_wr_data = 128'h0182A899980A29105010544912002884;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd43; w_wr_data = 128'h00902801081944454109924124A80406;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd44; w_wr_data = 128'h20A08106148210101860000108AA2290;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd45; w_wr_data = 128'h14822401A664A8262091090960001AA2;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd46; w_wr_data = 128'h46600059241218209AA5069612064100;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd47; w_wr_data = 128'h609864A51050514554A058941102A61A;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd48; w_wr_data = 128'h294AA0850285025404042A6202500460;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd49; w_wr_data = 128'h56802206415908100002049612828860;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd50; w_wr_data = 128'hA0145100214065402241500002851600;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd51; w_wr_data = 128'h6804806099011A806012091020021900;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd52; w_wr_data = 128'h840441840A221809002206182680900A;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd53; w_wr_data = 128'h6001290A0225198188864081A0151580;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd54; w_wr_data = 128'h40204140641100254400800061A80100;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd55; w_wr_data = 128'h85A54445692452258218460A2289A654;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd56; w_wr_data = 128'h0422801065280044229A582854858406;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd57; w_wr_data = 128'h25885442402109A0094A8A11AA2A2A4A;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd58; w_wr_data = 128'h64404008084482844800216080051200;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd59; w_wr_data = 128'h412268812A8829252214085800406210;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd60; w_wr_data = 128'h109904004410808022A2489421845018;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd61; w_wr_data = 128'h100252144AA9A5560002900895192584;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd62; w_wr_data = 128'h401041110116A464089014840948606A;
        @(negedge clk); w_wr_en = 1; w_wr_addr = 10'd63; w_wr_data = 128'h62A92028A90024108028020641898404;

        // Activations
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd0; act_wr_data = 8'hE0;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd1; act_wr_data = 8'hE9;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd2; act_wr_data = 8'hF1;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd3; act_wr_data = 8'hAF;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd4; act_wr_data = 8'h0A;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd5; act_wr_data = 8'hA3;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd6; act_wr_data = 8'hE6;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd7; act_wr_data = 8'h10;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd8; act_wr_data = 8'h47;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd9; act_wr_data = 8'hC1;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd10; act_wr_data = 8'h42;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd11; act_wr_data = 8'hF3;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd12; act_wr_data = 8'hE6;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd13; act_wr_data = 8'h37;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd14; act_wr_data = 8'h4E;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd15; act_wr_data = 8'hB2;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd16; act_wr_data = 8'hE0;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd17; act_wr_data = 8'h1B;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd18; act_wr_data = 8'h2D;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd19; act_wr_data = 8'hC8;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd20; act_wr_data = 8'hC3;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd21; act_wr_data = 8'h00;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd22; act_wr_data = 8'hC3;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd23; act_wr_data = 8'hEE;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd24; act_wr_data = 8'h3A;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd25; act_wr_data = 8'h06;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd26; act_wr_data = 8'h07;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd27; act_wr_data = 8'h81;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd28; act_wr_data = 8'hF0;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd29; act_wr_data = 8'h00;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd30; act_wr_data = 8'h44;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd31; act_wr_data = 8'hD4;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd32; act_wr_data = 8'h3D;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd33; act_wr_data = 8'hD3;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd34; act_wr_data = 8'h16;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd35; act_wr_data = 8'h00;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd36; act_wr_data = 8'h11;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd37; act_wr_data = 8'h34;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd38; act_wr_data = 8'h00;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd39; act_wr_data = 8'h16;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd40; act_wr_data = 8'h3A;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd41; act_wr_data = 8'hD6;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd42; act_wr_data = 8'hD1;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd43; act_wr_data = 8'h1A;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd44; act_wr_data = 8'h1E;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd45; act_wr_data = 8'h0C;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd46; act_wr_data = 8'h37;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd47; act_wr_data = 8'hD0;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd48; act_wr_data = 8'h06;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd49; act_wr_data = 8'hB0;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd50; act_wr_data = 8'hFA;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd51; act_wr_data = 8'hC4;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd52; act_wr_data = 8'h9C;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd53; act_wr_data = 8'hCF;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd54; act_wr_data = 8'hFE;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd55; act_wr_data = 8'h44;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd56; act_wr_data = 8'h28;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd57; act_wr_data = 8'h1F;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd58; act_wr_data = 8'h20;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd59; act_wr_data = 8'hF4;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd60; act_wr_data = 8'h1A;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd61; act_wr_data = 8'h0E;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd62; act_wr_data = 8'hD2;
        @(negedge clk); act_wr_en = 1; act_wr_addr = 10'd63; act_wr_data = 8'h8F;
        @(negedge clk); w_wr_en = 0; act_wr_en = 0;
        @(negedge clk); start = 1;
        @(negedge clk); start = 0;
        wait(done == 1'b1);
        #20;
        $display("HW_TOTAL_CYCLES=%0d", total_cycles);
        for (i = 0; i < 64; i = i + 1) begin
            out_rd_addr = i[9:0]; #5;
            $display("HW_OUT[%0d]=%d", i, out_rd_data);
        end
        $finish;
    end
endmodule
