/**********************************************************************
* File Name	: top.sv
* Description 	: top module
* Creation Date : 19-01-2021
* Last Modified : Tue 26 Jan 2021 08:53:58 PM PST
* Author 	: Vinod Sake
* Email 	: vinodsake042@gmail.com
* GitHub	: github.com/vinodsake
**********************************************************************/

module top;

	import uvm_pkg::*;
	import my_pkg::*;

	intf_dut dut_if();
	dut dut_1(dut_if);

	bind dut_1 dut_assertions dut_a (.dut_if(dut_if));

	initial begin
		dut_if.clock = 1'b0;
		forever #5 dut_if.clock = ~dut_if.clock;
	end

	initial begin
		dut_if.reset = 1'b1;
		#20;
		dut_if.reset = 1'b0;
	end

	initial begin
		uvm_config_db #(virtual intf_dut)::set(null, "*", "intf_dut", dut_if);
		//uvm_top.finish_on_completion = 1;
		run_test("my_test");
	end

endmodule
