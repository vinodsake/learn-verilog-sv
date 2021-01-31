/**********************************************************************
* File Name	: dut.sv
* Description 	: dut which prints cmd, address and data
* Creation Date : 19-01-2021
* Last Modified : Sat 23 Jan 2021 09:37:31 PM PST
* Author 	: Vinod Sake
* Email 	: vinodsake042@gmail.com
* GitHub	: github.com/vinodsake
**********************************************************************/

import uvm_pkg::*;

module dut(intf_dut dut_if);
	
	enum {IDLE, RUN, DONE} state, next_state;
	int comp_time, comp_time_next;
	logic [7:0] A_buf;
	logic [7:0] B_buf;
	logic [7:0] Result_buf;

	// seq logic
	always @ (posedge dut_if.clock) begin
		if(dut_if.reset == 1'b1) begin
			state <= IDLE;
			comp_time <= 0;
		end
		else begin
			state <= next_state;
			comp_time <= comp_time_next;
		end
	end

	// combinational logic
	always @(*) begin
		next_state = 'hx;
		case(state)
			IDLE :	begin 
					if(dut_if.start) begin 
						`uvm_info("dut" , $sformatf("Received cmd=%s A=%b B=%b", dut_if.cmd.name(), dut_if.A, dut_if.B), UVM_DEBUG)
						comp_time_next = compute[dut_if.cmd.name()]-1;
						A_buf = dut_if.A;
						B_buf = dut_if.B;			
						next_state = RUN;
					end
					else next_state = IDLE;
				end
			RUN :	begin
					if(comp_time == 0) begin 
						computation_engine();
						next_state = DONE;
					end
					else begin
						comp_time_next--;
						next_state = RUN;
					end
				end
			DONE :	next_state = IDLE;
			default:next_state = IDLE;
		endcase
	end
	
	// output assignment
	always @ (*) begin
		if(dut_if.reset == 1'b1) begin
			dut_if.done = 'b0;
			dut_if.Result = 'hxx;
			comp_time = 0;
			Result_buf = 'hxx;
		end
		else begin
			dut_if.Result = 'hxx;
			case(state)
				IDLE :	dut_if.done = 1'b1;
				RUN :	dut_if.done = 1'b0;
				DONE :	begin 
						dut_if.done = 1'b1;
						dut_if.Result = Result_buf;
					end
			endcase
		end
	end


	function computation_engine;
			case(dut_if.cmd)
				AND :	Result_buf = A_buf & B_buf;	
				OR :	Result_buf = A_buf | B_buf;
				XOR :	Result_buf = A_buf ^ B_buf;
				XNOR :	Result_buf = A_buf ~^ B_buf;
				SHR :	Result_buf = A_buf >> 1;
				SHL :	Result_buf = A_buf << 1;
				SET :	Result_buf = 'hFF;
				CLEAR :	Result_buf = 'h00;
				default:Result_buf = 'hXX;
			endcase
	endfunction
endmodule
