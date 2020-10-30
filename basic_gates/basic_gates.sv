// [5:0]result = AND, OR, XOR, XNOR, NAND, NOR
`timescale 1ns/1ns

module basic_gates (clk, rst, inA, inB, result);
	input inA, inB, clk, rst;
	output [5:0] result;
	reg [5:0] result;
	
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			result <= 0;
		end else begin
			result[0] <= inA & inB;
			result[1] <= inA | inB;
			result[2] <= inA ^ inB;
			result[3] <= inA ~^ inB;
			result[4] <= ~(inA & inB);
			result[5] <= ~(inA | inB);
		end
	end
endmodule

