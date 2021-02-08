/**********************************************************************
* File Name	: top_pkg.sv
* Description 	: top uvm pkg
* Creation Date : 07-02-2021
* Last Modified : Mon Feb  8 00:38:15 2021
* Author 	: Vinod Sake
* Email 	: vinodsake042@gmail.com
* GitHub	: github.com/vinodsake
**********************************************************************/

package top_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	import env_top_pkg::*;

	class test_top_base extends uvm_test;
		`uvm_component_utils(test_top_base)
		env_top m_env;

		function new(string name = "test_top_base", uvm_component parent = "");
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			m_env = env_top::type_id::create("m_env"); 
		endfunction

		function void init_seq(top_vseq_base vseq);
			vseq.A1 = m_env.env_1.m_agent_a.m_sequencer;
			vseq.B = m_env.env_1.m_agent_b.m_sequencer;
			vseq.A2 = m_env.env_2.m_agent_a.m_sequencer;
			vseq.C = m_env.env_2.m_agent_c.m_sequencer;
		endfunction
	endclass

	class init_vseq_from_test extends test_top_base;
		`uvm_component_utils(init_vseq_from_test)
		vseq_A_B vseq;
		vseq_A_C vseq_2;

		function new(string name = "init_vseq_from_test", uvm_component parent = "");
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			vseq = vseq_A_B::type_id::create("vseq");
			vseq_2 = vseq_A_C::type_id::create("vseq_2");
		endfunction
		task run_phase(uvm_phase);
			phase.raise_objection(this);
			init_seq(vseq);	// Assign sequencers
			vseq.start(null); // null as there is no target sequencer
			init_seq(vseq_2);
			vseq_2.start(null);
			phase.drop_objection(this);
		endtask
	endclass
endpackage
