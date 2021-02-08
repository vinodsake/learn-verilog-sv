/**********************************************************************
* File Name	: dut_asser.sv
* Description 	: sut assertions
* Creation Date : 26-01-2021
* Last Modified : Sun 31 Jan 2021 03:21:29 PM PST
* Author 	: Vinod Sake
* Email 	: vinodsake042@gmail.com
* GitHub	: github.com/vinodsake
**********************************************************************/
import my_pkg::*;

`define assert_clk(arg) \
       assert property (@(dut_if.mon_cb) disable iff (dut_if.reset) arg)	
`define assert_rst(arg) \
	assert property (@(dut_if.mon_cb) arg)

module dut_assertions(	intf_dut dut_if);

	ERROR_DUT_RESET_SHOULD_CAUSE_RESULTX_DONE0:
		`assert_rst(dut_if.mon_cb.reset |-> dut_if.drive_cb.Result===8'hxx && dut_if.drive_cb.done==1'b0);

	ERROR_CMD_AND_DONE1:
		`assert_clk(dut_if.mon_cb.cmd==AND && dut_if.mon_cb.start |=> $fell(dut_if.drive_cb.done) ##2 $rose(dut_if.drive_cb.done));
	ERROR_CMD_OR_DONE1:
		`assert_clk(dut_if.mon_cb.cmd==OR  && dut_if.mon_cb.start |=> $fell(dut_if.drive_cb.done) ##2 $rose(dut_if.drive_cb.done));
	ERROR_CMD_XOR_DONE1:
		`assert_clk(dut_if.mon_cb.cmd==XOR  && dut_if.mon_cb.start |=> $fell(dut_if.drive_cb.done) ##1 $rose(dut_if.drive_cb.done));
	ERROR_CMD_XNOR_DONE1:
		`assert_clk(dut_if.mon_cb.cmd==XNOR && dut_if.mon_cb.start |=> $fell(dut_if.drive_cb.done) ##2 $rose(dut_if.drive_cb.done));
	ERROR_CMD_SHR_DONE1:
		`assert_clk(dut_if.mon_cb.cmd==SHR && dut_if.mon_cb.start |=> $fell(dut_if.drive_cb.done) ##3 $rose(dut_if.drive_cb.done));
	ERROR_CMD_SHL_DONE1:
		`assert_clk(dut_if.mon_cb.cmd==SHL && dut_if.mon_cb.start |=> $fell(dut_if.drive_cb.done) ##3 $rose(dut_if.drive_cb.done));
	ERROR_CMD_SET_DONE1:
		`assert_clk(dut_if.mon_cb.cmd==SET && dut_if.mon_cb.start |=> $fell(dut_if.drive_cb.done) ##2 $rose(dut_if.drive_cb.done));
	ERROR_CMD_CLEAR_DONE1:
		`assert_clk(dut_if.mon_cb.cmd==CLEAR && dut_if.mon_cb.start|=> $fell(dut_if.drive_cb.done) ##1 $rose(dut_if.drive_cb.done));

endmodule
