/**********************************************************************
* File Name	: top_testbench.sv
* Description 	: connect uvm top pkg with test bench
* Creation Date : 08-02-2021
* Last Modified : Mon 08 Feb 2021 12:42:12 AM PST
* Author 	: Vinod Sake
* Email 	: vinodsake042@gmail.com
* GitHub	: github.com/vinodsake
**********************************************************************/

module top_testbench;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	import top_pkg::*

	//connect dut with interface

	//Drive clock
	forever begin

	end

	//Drive reset and required signals to start similation
	initial begin

	end

	//set uvm config_db with interface and run test 
	intial begin
		uvm_config_db ........
		run_test();
	end
endmodule
