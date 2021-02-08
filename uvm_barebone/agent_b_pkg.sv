/**********************************************************************
* File Name	: agent_b_pkg.sv
* Description 	: Agent b package which has seq_item, seq, agent(drv, mon)
* Creation Date : 07-02-2021
* Last Modified : Sun 07 Feb 2021 08:23:57 PM PST
* Author 	: Vinod Sake
* Email 	: vinodsake042@gmail.com
* GitHub	: github.com/vinodsake
**********************************************************************/

package agent_b_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

	class b_seq_item extends uvm_sequence_item;
		`uvm_object_utils(b_seq_item)
		
		rand int b;
		function new(string name = "b_seq_item");
			super.new(name);
		endfunction
	endclass

	class b_seq extends uvm_sequence_item;
		`uvm_object_utils(b_seq)

		function new(string name = "b_seq");
			super.new(name);
		endfunction

		task body;
			b_seq_item item = b_seq_item::type_id::create("b_seq_item");
			start_item(item);
			assert(item.randomize());
			finish_item(item);
		endtask
	endclass

	class b_driver extends uvm_component #(b_seq_item);
		`uvm_component_utils(b_driver)
		virtual intf_b vifb;

		function new(string name = "b_driver", uvm_component parent = "");
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			if(!(uvm_config_db #(virtual intf_b)::get(this,"","intf_b",vifb)))
				`uvm_fatal(get_name(),"cannot get virtual interface")
		endfunction

		task run_phase(uvm_phase);
			forever begin
			// always make sure there is a delay or clock event 
				seq_item_port.get_next_item(item);

				seq_item_port.item_done();
			end
		endtask
	endclass

	class b_monitor extends uvm_component;
		`uvm_componet_utils(b_monitor)
		virtual intf_b vifb;
		b_seq_item item;
		uvm_analysis_port #(b_seq_item) mon_b_analysis_port;
		
		function new(string name = "b_monitor", uvm_component parent = "");
			super.new(name,parent);
		endfunction
		
		function void build_phase(uvm_phase phase);
			if(!(uvm_config_db #(virtual intf_b)::get(this,"","intf_b",vifb)))
				`uvm_fatal(get_name(),"cannot get virtual interface")
			item = b_seq_item::type_id::create("item");
			mon_b_analysis_port = b_seq_item::type_id::create("mon_b_analysis_port");
		endfunction

		task run_phase(uvm_phase);
			forever begin
				// always make sure there is a delay or clock event 
				@(posedge <event>)
				item.<object> = vifb.<signal>;

				mon_b_analysis_port.write(item);
			end
		endtask
	endclass

	class b_agent extends uvm_component;
		`uvm_component_utils(b_agent)
		b_driver m_driver;
		b_monitor m_monitor;
		uvm_sequencer #(b_seq_item) m_sequencer;	

		function new(string name = "b_agent", uvm_component parent = "");
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			m_driver = b_driver::type_id::create("m_driver");
			m_monitor = b_monitor::type_id::create("m_monitor");
			m_sequencer = uvm_sequencer #(b_seq_item)::type_id::create("m_sequencer");
		endfunction

		function void connect_phase(uvm_phase phase);
			m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
		endfunction
	endclass
endpackage
