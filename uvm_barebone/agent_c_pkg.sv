/**********************************************************************
* File Name	: agent_c_pkg.sv
* Description 	: Agent c package which has seq_item, seq, agent(drv, mon)
* Creation Date : 07-02-2021
* Last Modified : Sun 07 Feb 2021 08:28:31 PM PST
* Author 	: Vinod Sake
* Email 	: vinodsake042@gmail.com
* GitHub	: github.com/vinodsake
**********************************************************************/

package agent_c_pkg;

import uvm_pkg:*;
`include "uvm_macros.svh"

	class c_seq_item extends uvm_sequence_item;
		`uvm_object_utils(c_seq_item)

		rand int c;
		function new(string name = "c_seq_item");
			super.new(name);
		endfunction
	endclass

	class c_seq extends uvm_sequence #(c_seq_item);
		`uvm_object_utils(c_seq)

		function new(string name = "c_seq");
			super.new(name)
		endfunction

		task body;
			c_seq_item item = c_seq_item::type_id::create("item");
			repeat(n) begin
				start_item(item);
				asset(item.randomize());
				finish_item(item);
			end
		endtask
	endclass

	class c_driver extends uvm_driver #(c_seq_item);
		`uvm_component_utils(c_driver)
		virtual intf_c vifa;
		
		function new(string name = "c_driver", uvm_component parent = "");
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			if(!uvm_config_db #(virtual intf_c)::get(this,"", "intf_c", vifa))
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

	class c_monitor extends uvm_monitor;
		`uvm_component_utils(c_monitor)
		virtual intf_c vifa;
		c_seq_item item;
		uvm_cnalysis_port #(c_seq_item) mon_c_analysis_port;

		function new(string name = "c_monitor", uvm_component parent = "");
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			if(!uvm_config_db #(virtual intf_c)::get(this,"", "intf_c", vifa))
				`uvm_fatal(get_name(),"Cannot get virtual interface")
			item = c_seq_item::type_id::create("item");
			mon_c_analysis_port = c_seq_item::type_id::create("mon_c_analysis_port"); 
		endfunction

		task run_phase(uvm_phase phase);
			forever begin
				// always make sure there is a delay or clock event 
				@(posedge <event>)
				item.<object> = vifa.<signal>;

				mon_c_analysis_port.write(item);
			end
		endtask
	endclass

	class c_agent extends uvm_component;
		`uvm_component_utils(c_agent)
		
		c_driver m_driver;
		c_monitor m_monitor;
		uvm_sequencer #(c_seq_item) m_sequencer;

		function new(string name = "c_agent", uvm_component parent = "");
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			m_driver = c_driver::type_id::create("m_driver");
			m_monitor = c_monitor::type_id::create("m_monitor");
			m_sequencer = uvm_sequencer #(c_seq_item)::type_id::create("m_sequencer");	
		endfunction

		function void connect_phase(uvm_phase phase);
			m_driver.seq_item_port.connect(m_sequencer.se_item_export);
		endfunction

	endclass
endpackage

