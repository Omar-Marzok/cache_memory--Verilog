module cache_controller #(parameter RISC_data = 32, main_data = 128,cache_depth = 32)(
  
 input  wire  	[7:0] 	A,
 input  wire            clk,RST,
 input 	wire			RISC_WE,RISC_RE,
 input	wire			mem_done,
// output reg		[1:0]	ResultSrc,
 output reg				stall,
 output reg				WSource,
 output reg				mem_RE,
 output reg				mem_WE,
 output reg				cache_WE
);

wire tag_hit, valid_bit, hit;
reg [1:0] current_state,next_state;
reg [3:0] tag_valid [0: cache_depth-1];
integer i;
localparam [1:0] 	IDLE  = 2'b00,
					READ  = 2'b01,
					WRITE = 2'b10;

	
always@(negedge clk or negedge RST)
begin
	if(!RST)
	begin
		current_state <= IDLE;
		for (i=0 ; i < cache_depth ;i=i+1)
			tag_valid[i][3] <= 1'b0;
	end
	else
	begin 
		current_state <= next_state;
		if (mem_done && next_state == READ)
		 begin
			tag_valid[A[4:0]][3] <=1'b1;
			tag_valid[A[4:0]][2:0] <= A[7:5];
		end
	end
end

// main decoder
always @(*)
begin
	stall = 1'b0;
	mem_RE = 1'b0;
	mem_WE = 1'b0;
	cache_WE = 1'b0;
	WSource = 1'b1;
	case(current_state)
	IDLE: 		begin
				if (RISC_WE)
					next_state = WRITE;
				else if (RISC_RE && !hit)
					next_state = READ;
				else
					next_state = IDLE;
				end
	READ: 		begin
				stall = 1'b1;
				mem_RE = 1'b1;
				cache_WE = 1'b1;
				WSource = 1'b1;
				if (mem_done)
				 begin
					stall = 1'b0;
					next_state = IDLE;
				 end
				else
				 begin
					next_state = READ;
				 end
				end
	WRITE: 		begin
				stall = 1'b1;
				mem_WE = 1'b1;
				if (hit)
				 begin
					cache_WE = 1'b1;
					WSource = 1'b0;
				 end
				else
				 begin
					cache_WE = 1'b0;
					WSource = 1'b1;
				 end
				if (mem_done)
				 begin
					stall = 1'b0;
					next_state = IDLE;
				 end
				else
				 begin
					next_state = WRITE;
				 end
				end
	default:	begin
				next_state = IDLE;
				end
	endcase
end

assign tag_hit = (tag_valid[A[4:0]][2:0] == A[7:5] )? 1:0;
assign valid_bit = tag_valid[A[4:0]][3];
assign hit = (valid_bit && tag_hit)? 1:0;

endmodule


