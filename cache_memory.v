module cache_memory #(parameter RISC_data = 32, main_data = 128,cache_depth = 32)(
input  wire						clk,WE,
input  wire						WSource,
input  wire 	[RISC_data-1:0]	WD_RISC,
input  wire 	[main_data-1:0]	WD_main, 
input  wire		[4:0]			A,
input  wire 	[1:0]			word_loc,
output reg 		[RISC_data-1:0]	RD_RISC
);


reg [main_data-1:0] data_in;
reg [main_data -1:0] cache_mem [0:cache_depth -1];


always @(posedge clk)
begin
	if (WE)
    begin
        cache_mem[A] <= data_in;
    end
 end

 // main memory write or RISC Write
always@(*)
begin
	if (WSource)
		data_in = WD_main ;
	else
	case(word_loc)
	2'b00: data_in = {cache_mem[A][127:32], WD_RISC};
	2'b01: data_in = {cache_mem[A][127:63],WD_RISC, cache_mem[A][31:0]};
	2'b10: data_in = {cache_mem[A][127:96],WD_RISC, cache_mem[A][63:0]};
	2'b11: data_in = {WD_RISC , cache_mem[A][95:0]};
	endcase
end

 // Read a word
always@(*)
begin
	case(word_loc)
	2'b00: RD_RISC = cache_mem[A][31:0];
	2'b01: RD_RISC = cache_mem[A][63:32];
	2'b10: RD_RISC = cache_mem[A][95:64];
	2'b11: RD_RISC = cache_mem[A][127:96];
	endcase
end

endmodule