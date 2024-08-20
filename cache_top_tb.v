module cache_top_tb();

reg 		clk;
reg 		RST;
reg 		MemRead,MemWrite;
reg  [9:0]	WordAddress;
reg  [31:0] DataIn;
wire [31:0] DataOut;
wire 		stall;

// instantiate device to be tested
cache_top DUT(
.clk(clk),
.RST(RST),
.RE(MemRead),
.WE(MemWrite),
.A(WordAddress),
.DataIn(DataIn),
.DataOut(DataOut),
.stall(stall)
);
    // initialize test

	// reg [31:0]  randomized_Data  [1024:0] ;
	// reg [9:0]   randomized_waddr [127:0] ;
	reg [9:0]   randomized_raddr         ;
	// reg [127:0] valid				     ;
	reg			check 					 ;
	integer i;

	initial begin
		initialize();
		reset();
		write_addr(0);
		repeat(6) begin
			@(negedge clk);
		end

		write_addr(1);
		repeat(6) begin
			@(negedge clk);
		end


		write_addr(2);
		repeat(6) begin
			@(negedge clk);
		end

		write_addr(3);
		repeat(6) begin
			@(negedge clk);
		end
		read_addr (0);
		@(negedge clk);
		check_data();
		@(negedge clk);

		for (i = 0;i<1024;i = i + 1) begin
			write_addr(i);
			repeat(6) begin
				@(negedge clk);
			end
		end


		for (i = 0;i<10;i = i + 1) begin
			read_addr ($random);
			@(negedge clk);
			check_data();
			@(negedge clk);
		end
		@(negedge clk);
		read_addr (5);
		@(negedge clk);
		check_data();
		@(negedge clk);
		write_addr(5);
		repeat(6) begin
			@(negedge clk);
		end
		read_addr (5);
		@(negedge clk);
		check_data();
		@(negedge clk);



		for (i = 0;i<1000;i = i + 1) begin
			write_addr($random);
			repeat(6) begin
				@(negedge clk);
			end
			read_addr ($random);
			@(negedge clk);
			check_data();
			@(negedge clk);
		end
		$stop;

	end

	task initialize;
		
		begin
			clk 	 	= 0;
			RST 	 	= 1;
			MemRead  	= 0;
			MemWrite 	= 0;
			WordAddress = 0;
			DataIn		= 0;
		end

	endtask

	task reset;

		begin
			RST = 1;
			@(negedge clk);
			RST = 0;
			@(negedge clk);
			RST = 1;
		end

	endtask


	task write_addr;
	input  reg [9:0]  addr;
		begin
			MemWrite 			  	   = 1    	 ;
			MemRead 			  	   = 0    	 ;
			WordAddress 		  	   = addr    ;
			DataIn				 	   = $random ;
		end

	endtask


	// task write_rand;
	// 	begin
	// 		MemWrite 			  	   		   = 1    		 ;
	// 		MemRead 			  	   		   = 0    		 ;
	// 		WordAddress 				  	   = $random 	 ;
	// 		DataIn				 	   		   = $random 	 ;
	// 		randomized_Data[WordAddress[6:0]]  = DataIn  	 ;
	// 		randomized_waddr[WordAddress[6:0]] = WordAddress ;
	// 		valid[WordAddress[6:0]]		   	   = 1 		     ;
	// 	end
	// endtask


	task read_addr;
	input [9:0] addr;
		begin
			MemRead 			  	   		  = 1    						 ;
			MemWrite 			  	   		  = 0    						 ;
			WordAddress 					  = addr						 ;
			randomized_raddr 				  = WordAddress 				 ;
		end
	endtask

	// task read_rand;
	// input [9:0] randomized;
	// 	begin
	// 		MemRead 			  	   		  = 1    						 ;
	// 		MemWrite 			  	   		  = 0    						 ;
	// 		while (!valid[randomized]) begin
	// 			randomized = $random;
	// 			@(negedge clk);
	// 		end
	// 		WordAddress 					  = randomized_waddr[randomized] ;
	// 		randomized_raddr 				  = WordAddress 				 ;
	// 	end
	// endtask

	task check_data;
		reg [31:0]	RD_RISC;
		begin
			MemWrite 			  	   		  = 0    						 ;
			check 							  = 1 							 ;
			@(negedge clk);
			
			case(WordAddress[1:0])
			2'b00: RD_RISC = DUT.U2.data_mem[WordAddress[9:2]][31:0];
			2'b01: RD_RISC = DUT.U2.data_mem[WordAddress[9:2]][63:32];
			2'b10: RD_RISC = DUT.U2.data_mem[WordAddress[9:2]][95:64];
			2'b11: RD_RISC = DUT.U2.data_mem[WordAddress[9:2]][127:96];
			endcase
			
			if(stall)begin
				repeat(3) begin
					@(negedge clk);
				end
				MemRead 			  	   		  = 0    				     ;
				if (DataOut == RD_RISC) begin
					$display("Succeeded at time = %t",$time);
				end
				else begin
					$display("Failed at time = %t",$time);
				end
			end
			else begin
				MemRead 			  	   		  = 0    				     ;
				if (DataOut == RD_RISC) begin
					$display("Succeeded at time = %t",$time);
				end
				else begin
					$display("Failed at time = %t",$time);
				end
			end
			check 							  = 0 							 ;
		end
	endtask

    // generate clock to sequence tests
always
begin
    clk <= 0; # 5; clk <= 1; # 5;
end
	
endmodule

