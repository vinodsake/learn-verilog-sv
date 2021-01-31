/**********************************************************************
* File Name	: intf_dut.sv
* Description 	: interface to dut
* Creation Date : 19-01-2021
* Last Modified : Sun 31 Jan 2021 03:30:42 PM PST
* Author 	: Vinod Sake
* Email 	: vinodsake042@gmail.com
* GitHub	: github.com/vinodsake
**********************************************************************/
`include "pkg.sv"
import my_pkg::*;

interface intf_dut;
	T_CMD cmd;
	logic [7:0] A;
	logic [7:0] B;
	logic [7:0] Result;	
	logic clock;
	logic reset;
	logic done;
	logic start;

	// Clocking block to drive dut
	clocking drive_cb @(posedge clock);
		default input #1step output #1step;
		input Result;
		input done;
		output A;
		output B;
		output cmd;
		output reset;
		output start;
	endclocking
	
	// Clocking block to mon dut
	default clocking mon_cb @(posedge clock);
		default input #1step output #1step;
		output Result;
		output done;
		input A;
		input B;
		input cmd;
		input reset;
		input start;
	endclocking

endinterface
