/**********************************************************************
* File Name	: gates.sv
* Description 	:
* Creation Date : 25-11-2020
* Last Modified : Wed 25 Nov 2020 09:00:36 AM PST
* Author 	: Vinod Sake
* Email 	: vinodsake042@gmail.com
* GitHub	: github.com/vinodsake
**********************************************************************/

module gates(
	input A,
	input B,
	output And_t,
	output Or_t,
	output Xor_t,
	output Xnor_t
);
	reg And_t, Or_t, Xor_t, Xnor_t;
	assign And_t = A & B;
	assign Or_t = A | B;
	assign Xor_t = A ^ B;
	assign Xnor_t = ~(A ^ B);
	
endmodule
