module data_memory #(parameter RISC_data=32, main_data = 128,main_depth = 256)(
  
 input  wire               	  clk,
 input  wire               	  WE,
 input  wire               	  RE,
 input 	wire  [RISC_data-1:0] WD_RISC,
 input 	wire  [1:0]			  word_loc,
 input 	wire  [7:0]        	  A,
 output reg				  mem_done,
 output reg   [main_data-1:0] RD );

reg flag;
reg [2:0] count;
reg [main_data-1:0] data_in;
reg [main_data-1:0] data_mem [0:main_depth -1];

always @(posedge clk) 
begin
	if (mem_done)
		count <=0;	
	else if (WE && count == 3'b0)
    begin
        data_mem[A] <= data_in;
		count<= count + 1;
    end
	else if (RE && count == 3'b0)
	begin
		RD <= data_mem[A];
		count<= count + 1;
	end	
	else if ((count != 3'b100) && (count != 3'b000))
		count<= count + 1;
	else
		count<=0;
 end

 // write back and write away
always@(*)
begin
	case(word_loc)
	2'b00: data_in = {data_mem[A][127:32], WD_RISC};
	2'b01: data_in = {data_mem[A][127:63],WD_RISC, data_mem[A][31:0]};
	2'b10: data_in = {data_mem[A][127:96],WD_RISC, data_mem[A][63:0]};
	2'b11: data_in = {WD_RISC , data_mem[A][95:0]};
	endcase
end

always @(negedge clk) 
begin
if (count == 3'b100)
begin
 mem_done <= 1'b1;
 flag <= 1'b1;
end
else if (flag )
begin
 mem_done <= 1'b1;
 flag <= 1'b0;
end
else
begin
 mem_done <= 1'b0;
 flag <= 1'b0;
end
end
endmodule