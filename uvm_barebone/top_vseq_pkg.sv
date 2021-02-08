/**********************************************************************
* File Name	: top_vseq_pkg.sv
* Description 	: top virtual sequence
* Creation Date : 07-02-2021
* Last Modified : Mon Feb  8 00:23:06 2021
* Author 	: Vinod Sake
* Email 	: vinodsake042@gmail.com
* GitHub	: github.com/vinodsake
**********************************************************************/

package top_vseq_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import agent_a_pkg::*
import agent_b_pkg::*
import agent_c_pkg::*

	class top_vseq_base extends uvm_sequence #(uvm_sequence_item);
		`uvm_component_utils(top_vseq_base)

		uvm_sequencer #(a_seq_item) A1;
		uvm_sequencer #(a_seq_item) A2;
		uvm_sequencer #(a_seq_item) B;
		uvm_sequencer #(a_seq_item) C;

		function new(string name = "top_vseq_base");
			super.new(name);
		endfunction
	endclass

	class vseq_A_B extends top_vseq_base;
		`uvm_component_utils(vseq_A_B)

		function new(string name = "vseq_A_B");
			super.new(name);
		endfunction

		task body();
			a_seq a = a_seq::type_id::create("a_seq");
			b_seq b = b_seq::type_id::create("b_seq");

			fork 
				a.start(A1);
				b.start(B);
			join
		endtask
	endclass
	
	class vseq_A_C extends top_vseq_base;
		`uvm_component_utils(vseq_A_C)

		function new(string name = "vseq_A_C");
			super.new(name);
		endfunction

		task body();
			a_seq a = a_seq::type_id::create("a_seq");
			c_seq c = c_seq::type_id::create("c_seq");

			fork 
				a.start(A2);
				b.start(C);
			join
		endtask
	endclass
endpackage
