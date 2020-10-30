`define delay 10

module basic_gates_tb;
	reg clk;
	reg rst;
	reg inA;
	reg inB;
	wire [5:0] result;

	//Instantiate design under test
	basic_gates BasicGates(
		.clk(clk),
		.rst(rst),
		.inA(inA),
		.inB(inB),
		.result(result)
	);

	initial begin
		clk = 0;
		rst = 0;
		inA = 0;
		inB = 0;

		display();
		rst = 1;
		#2 rst = 0;
		#14;
		display();
		#`delay {inA,inB} = 1;
		display();
		#`delay {inA,inB} = 2;
		display();
		#`delay {inA,inB} = 3;
		display();
		#`delay $finish;
	end

	always begin
		#5 clk = ~clk;
	end	

	task display;
	  begin	
		#2;
		$display("%0t : %b & %b = %b", $time, inA, inB, result[0]);
		$display("%0t : %b | %b = %b", $time, inA, inB, result[1]);
		$display("%0t : %b ^ %b = %b", $time, inA, inB, result[2]);
		$display("%0t : %b ~^ %b = %b", $time, inA, inB, result[3]);
		$display("%0t : %b ~& %b = %b", $time, inA, inB, result[4]);
		$display("%0t : %b ~| %b = %b", $time, inA, inB, result[5]);
		$display("----------------------------------");
	   end
	endtask
endmodule
