/**********************************************************************
* File Name	: pkg.sv
* Description 	:
* Creation Date : 19-01-2021
* Last Modified : Sun 31 Jan 2021 03:39:03 PM PST
* Author 	: Vinod Sake
* Email 	: vinodsake042@gmail.com
* GitHub	: github.com/vinodsake
**********************************************************************/
`ifndef _my_pkg_
`define _my_pkg_
`include "uvm_macros.svh"

package my_pkg;

	import uvm_pkg::*;

	typedef enum logic [2:0] { AND, OR, XOR, XNOR, SHR, SHL, SET, CLEAR} T_CMD;

	int compute[string] = 
		{
		"AND" 	: 2,
		"OR"	: 2,
		"XOR"	: 1,
		"XNOR"	: 2,
		"SHR"	: 3,
		"SHL"	: 3,
		"SET"	: 2,
		"CLEAR"	: 1
	};

	class my_transaction extends uvm_sequence_item;
		`uvm_object_utils(my_transaction)
		
		rand T_CMD cmd_t;
		rand logic [7:0] A;
	        rand logic [7:0] B;
		logic [7:0] Result;
		logic start;
		logic done;

		constraint c_AB { A >= 0; A < 256; B >= 0; B < 256; }
		constraint cmd { cmd_t >= 0; cmd_t < 8; }	
		
		function new(string name = "");
			super.new(name);
		endfunction
	endclass

	typedef uvm_sequencer #(my_transaction) my_sequencer;
	
	class my_sequence extends uvm_sequence #(my_transaction);
		`uvm_object_utils(my_sequence)

		function new(string name = "");
			super.new(name);
		endfunction

		task body;
			`uvm_info("my_sequence", "starting sequence", UVM_FULL)
			if(starting_phase != null)
				starting_phase.raise_objection(this);
			repeat(5000) begin
				req = my_transaction::type_id::create("req");
				start_item(req);
				`uvm_info("my_sequence", "sending packet", UVM_FULL)
				if (!req.randomize())
					`uvm_error("my_sequence", "Randomization failed")
				finish_item(req);
			end
			
			if(starting_phase != null)
				starting_phase.drop_objection(this);
		endtask
	endclass

	class my_driver extends uvm_driver #(my_transaction);
		`uvm_component_utils(my_driver)
		virtual intf_dut dut_vi;

		function new(string name, uvm_component parent);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			if(!uvm_config_db #(virtual intf_dut)::get(this,"", "intf_dut",dut_vi))
				`uvm_error("my_driver", "ucm_config_db::get failed")
		endfunction

		task run_phase(uvm_phase phase);
			super.run_phase(phase);
			`uvm_info("my_driver","starting run phase",UVM_FULL)
			forever begin
				@(posedge dut_vi.clock);
				if(dut_vi.done) begin
					seq_item_port.get_next_item(req);
					dut_vi.start = 1'b1;
					dut_vi.cmd = req.cmd_t;
					dut_vi.A = req.A;
					dut_vi.B = req.B;
					@(posedge dut_vi.clock);
					dut_vi.start = 1'b0;
					seq_item_port.item_done();
				end
			end
		endtask
	endclass

	class my_monitor extends uvm_monitor;
		`uvm_component_utils(my_monitor)
		virtual intf_dut dut_vi;
		my_transaction pkt;
		uvm_analysis_port #(my_transaction) mon_analysis_port;
		function new(string name, uvm_component parent);
			super.new(name, parent);
		endfunction
		
		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			if(!uvm_config_db #(virtual intf_dut)::get(this, "", "intf_dut", dut_vi))
				`uvm_error("my_monitor","uvm_config_db::get failed")
			mon_analysis_port = new("mon_analysis_port",this);
			pkt = my_transaction::type_id::create("pkt",this);
		endfunction

		function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);	
		endfunction

		virtual task run_phase(uvm_phase phase);
			super.run_phase(phase);
			`uvm_info("my_monitor", "Runing monitor", UVM_FULL)

			forever begin
				@(posedge dut_vi.start);
				pkt.A = dut_vi.A;
				pkt.B = dut_vi.B;
				pkt.cmd_t = dut_vi.cmd;
				pkt.start = dut_vi.start;
				mon_analysis_port.write(pkt);
				
				@(posedge dut_vi.done);
				pkt.Result = dut_vi.Result;
				pkt.start = dut_vi.start;
				pkt.done = dut_vi.done;
				mon_analysis_port.write(pkt);
				//`uvm_info("my_monitor", $sformatf("cmd=%s A=%b B=%b Result=%b", dut_vi.cmd.name(), dut_vi.A, dut_vi.B, dut_vi.Result), UVM_FULL)
			end
		endtask
	endclass

	class my_scoreboard extends uvm_scoreboard;
		`uvm_component_utils(my_scoreboard)
		uvm_analysis_imp #(my_transaction, my_scoreboard) ap_export;

		my_transaction Tx, Rx;
		logic [7:0] SC_Result;

		function new(string name, uvm_component parent);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			super.build_phase(phase);
			ap_export = new("ap_export",this);
			Tx = my_transaction::type_id::create("Tx");
			Rx = my_transaction::type_id::create("Rx");
		endfunction

		virtual function void write(my_transaction pkt);
			if(pkt.start == 1'b1) begin
				Tx = pkt;
			end
			else if(pkt.done == 1'b1) begin
				Rx = pkt;
			end
			else
				`uvm_error("my_scoreboard","pkt doesnt have start or done")
		endfunction

		task run_phase(uvm_phase phase);
			forever begin
					@(posedge Rx.done);	// Adding delay as any run phase need to have delay.
					`uvm_info("my_scoreboard", "Received Tx & Rx", UVM_FULL)
					`uvm_info("my_scoreboard", $sformatf("Tx: cmd:%s A:%b B:%b Result:%b",Tx.cmd_t, Tx.A, Tx.B, Tx.Result), UVM_HIGH)
					`uvm_info("my_scoreboard", $sformatf("Rx: cmd:%s A:%b B:%b Result:%b",Rx.cmd_t, Rx.A, Rx.B, Rx.Result), UVM_HIGH)
					case(Tx.cmd_t)
						AND :	 SC_Result = Rx.A & Rx.B;
						OR :	 SC_Result = Rx.A | Rx.B;
						XOR :    SC_Result = Rx.A ^ Rx.B;
						XNOR :   SC_Result = Rx.A~^ Rx.B;
						SHR :    SC_Result = Rx.A >> 1;
						SHL :    SC_Result = Rx.A << 1;
						SET :    SC_Result = 'hFF;
						CLEAR :  SC_Result = 'h00;
						default: SC_Result = 'hXX;       
					endcase
					
					if(Rx.Result === SC_Result)
						`uvm_info("my_scoreboard","passed",UVM_FULL)
					else begin
						`uvm_error("my_scoreboard",$sformatf("Tx.cmd:%s Rx.Result:%b SC.Result:%b",Tx.cmd_t, Rx.Result,SC_Result))
					end
					//reset Tx and Rx
					Tx.start = 0;
					Rx.done = 0;
			end
		endtask
	endclass

	class my_coverage extends uvm_subscriber #(my_transaction);
		`uvm_component_utils(my_coverage)
		uvm_analysis_imp #(my_transaction, my_coverage) ap_export;
		my_transaction Tx;
		
		covergroup m_cov;
			cp_A: coverpoint Tx.A {
				bins zeros = {8'h00};
				bins ones = {8'hFF};
				bins others = default;
			}
			cp_B: coverpoint Tx.B {
				bins zeros = {8'h00};
				bins ones = {8'hFF};
				bins others = default;
			}
			cp_cmd: coverpoint Tx.cmd_t;
		endgroup

		function new(string name, uvm_component parent);
			super.new(name,parent);
			ap_export = new("ap_export",this);
			m_cov = new();
			Tx = my_transaction::type_id::create("Tx",this);
		endfunction

		function void write(my_transaction pkt);
			if(pkt.start == 1'b1) begin
				`uvm_info(get_type_name(),"received pkt",UVM_MEDIUM)
				Tx = pkt;
					`uvm_info("my_scoreboard", $sformatf("Tx: cmd:%s A:%b B:%b Result:%b",Tx.cmd_t, Tx.A, Tx.B, Tx.Result), UVM_MEDIUM)
				m_cov.sample();
			end
		endfunction

		function void report_phase(uvm_phase phase);
			`uvm_info(get_type_name(),$sformatf("coverage: %3.1f%%", m_cov.get_inst_coverage()),UVM_MEDIUM)
		endfunction
		
		function void extract_phase(uvm_phase phase);
        		`uvm_info(get_full_name(),"this is extract phase",UVM_LOW)
    		endfunction
    		function void check_phase(uvm_phase phase);
        		`uvm_info(get_full_name(),"this is check phase",UVM_LOW)
    		endfunction
    		function void final_phase(uvm_phase phase);
        		`uvm_info(get_full_name(),"this is final phase",UVM_LOW)
    		endfunction
	endclass

	class my_agent extends uvm_agent;
		`uvm_component_utils(my_agent)
		my_driver m_driv;
		my_sequencer m_seqr;
		my_monitor m_mon;

		function new(string name, uvm_component parent);
			super.new(name,parent);
		endfunction
		
		function void build_phase(uvm_phase phase);	
			m_driv = my_driver::type_id::create("m_driv", this);
			m_seqr = my_sequencer::type_id::create("m_seqr", this);
			m_mon = my_monitor::type_id::create("m_mon", this);
		endfunction

		function void connect_phase(uvm_phase phase);
			m_driv.seq_item_port.connect(m_seqr.seq_item_export);
		endfunction
	endclass

	class my_env extends uvm_env;
		`uvm_component_utils(my_env)

		my_agent m_agent;
		my_scoreboard m_scbd;
		my_coverage m_cov;

		function new(string name, uvm_component parent);
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			m_agent = my_agent::type_id::create("m_agent", this);
			m_scbd = my_scoreboard::type_id::create("m_scbd", this);
			m_cov = my_coverage::type_id::create("m_cov", this);
		endfunction

		function void connect_phase(uvm_phase phase);
			m_agent.m_mon.mon_analysis_port.connect(m_scbd.ap_export);	
			m_agent.m_mon.mon_analysis_port.connect(m_cov.ap_export);	
		endfunction
	endclass
	


	class my_test extends uvm_test;
		`uvm_component_utils(my_test)

		my_env m_env;

		function new(string name, uvm_component parent);
			super.new(name, parent);
		endfunction

		function void build_phase(uvm_phase phase);
			m_env = my_env::type_id::create("my_env", this);
		endfunction

		function void end_of_elaboration_phase(uvm_phase phase);
			uvm_top.print_topology();
		endfunction

		task run_phase(uvm_phase phase);
			my_sequence seq;
			seq = my_sequence::type_id::create("seq",this);
			
			if (!seq.randomize())
				`uvm_error("my_test", "Seq randomization failed")

			seq.starting_phase = phase;
			phase.raise_objection(this);
			`uvm_info("run_phase","starting sequence on seqr",UVM_FULL)
			seq.start(m_env.m_agent.m_seqr);
			phase.drop_objection(this);
		endtask
	endclass

endpackage
`endif

