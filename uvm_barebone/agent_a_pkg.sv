/**********************************************************************
* File Name	: agent_a_pkg.sv
* Description 	: Agent a package which has seq_item, seq, agent(drv, mon)
* Creation Date : 07-02-2021
* Last Modified : Sun 07 Feb 2021 07:39:50 PM PST
* Author 	: Vinod Sake
* Email 	: vinodsake042@gmail.com
* GitHub	: github.com/vinodsake
**********************************************************************/

package agent_a_pkg;

import uvm_pkg:*;
`include "uvm_macros.svh"

	class a_seq_item extends uvm_sequence_item;
		`uvm_object_utils(a_seq_item)

		function new(string name = "a_seq_item");
			super.new(name);
		endfunction
	endclass

	class a_seq extends uvm_sequence #(a_seq_item);
		`uvm_object_utils(a_seq)

		function new(string name = "a_seq");
			super.new(name)
		endfunction

		task body;
			a_seq_item item = a_seq_item::type_id::create("item");
			repeat(n) begin
				start_item(item);
				asset(item.randomize());
				finish_item(item);
			end
		endtask
	endclass

	class a_driver extends uvm_driver #(a_seq_item);
		`uvm_component_utils(a_driver)
		virtual intf_a vif;
		
		function new(string name = "a_driver", uvm_component parent = "");
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			if(!uvm_config_db #(virtual intf_a)::get(this,"", "intf_a", vif))
				`uvm_fatal(get_name(),"Cannot get virtual interface")
		endfunction

		task run_phase(uvm_phase phase);
			forever begin
				// always make sure there is a delay or clock event 
				seq_item_port.get_next_item(item);

				seq_item_port.item_done();
			end
		endtask
	endclass

	class a_monitor extends uvm_monitor;
		`uvm_component_utils(a_monitor)
		virtual intf_a vif;
		a_seq_item item;
		uvm_analysis_port #(a_seq_item) mon_a_analysis_port;

		function new(string name = "a_monitor", uvm_component parent = "");
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			if(!uvm_config_db #(virtual intf_a)::get(this,"", "intf_a", vif))
				`uvm_fatal(get_name(),"Cannot get virtual interface")
			item = a_seq_item::type_id::create("item");
			mon_a_analysis_port = a_seq_item::type_id::create("mon_a_analysis_port"); 
		endfunction

		task run_phase(uvm_phase phase);
			forever begin
				// always make sure there is a delay or clock event 
				@(posedge <event>)
				item.<object> = vif.<signal>;

				mon_a_analysis_port.write(item);
			end
		endtask
	endclass

	class a_agent extends uvm_component;
		`uvm_component_utils(a_agent)
		
		a_driver m_driver;
		a_monitor m_monitor;
		uvm_sequencer #(a_seq_item) m_sequencer;

		function new(string name = "a_agent", uvm_component parent = "");
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			m_driver = a_driver::type_id::create("m_driver");
			m_monitor = a_monitor::type_id::create("m_monitor");
			m_sequencer = uvm_sequencer #(a_seq_item)::type_id::create("m_sequencer");	
		endfunction

		function void connect_phase(uvm_phase phase);
			m_driver.seq_item_port.connect(m_sequencer.se_item_export);
		endfunction

	endclass
endpackage
