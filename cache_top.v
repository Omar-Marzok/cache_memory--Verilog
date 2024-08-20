module cache_top #(parameter RISC_data = 32, main_data = 128,cache_depth = 32)(
input  wire 				 clk,RST,
input  wire 				 RE,WE,
input  wire  [9:0]			 A,
input  wire  [RISC_data-1:0] DataIn,
output wire	 [RISC_data-1:0] DataOut,
output wire 				 stall
);

wire mem_done,WSource,mem_RE,mem_WE,cache_WE;
wire [main_data-1:0] main_OutData;

cache_controller U0 (
.A(A[9:2]),
.clk(clk),
.RST(RST),
.RISC_WE(WE),
.RISC_RE(RE),
.mem_done(mem_done),
//.ResultSrc,
.stall(stall),
.WSource(WSource),
.mem_RE(mem_RE),
.mem_WE(mem_WE),
.cache_WE(cache_WE)
);

 cache_memory U1(
.clk(clk),
.WE(cache_WE),
.WSource(WSource),
.WD_RISC(DataIn),
.WD_main(main_OutData), 
.A(A[6:2]),
.word_loc(A[1:0]),
.RD_RISC(DataOut)
);

data_memory U2(
.clk(clk),
.WE(mem_WE),
.RE(mem_RE),
.WD_RISC(DataIn),
.word_loc(A[1:0]),
.A(A[9:2]),
.mem_done(mem_done),
.RD(main_OutData) 
);

endmodule