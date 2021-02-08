/**********************************************************************
* File Name	: env_2_pkg.sv
* Description 	: env 2 pkg
* Creation Date : 07-02-2021
* Last Modified : Sun 07 Feb 2021 11:45:49 PM PST
* Author 	: Vinod Sake
* Email 	: vinodsake042@gmail.com
* GitHub	: github.com/vinodsake
**********************************************************************/

package env_2_pkg;
import uvm_pkg::*
`include "uvm_macros.svh"
import agent_a_pkg::*;
import agent_c_pkg::*;

	class env_2 extends uvm_env;
		`uvm_component_utils(env_2)
		a_agent m_agent_a;
		c_agent m_agent_b;

		function new(string name = "env1",uvm_component parent = "");
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			m_agent_a = a_agent::type_id::create("m_agent_a"); 
			m_agent_c = c_agent::type_id::create("m_agent_c"); 
		endfunction

		function void connect_phase(uvm_phase phase);
			// connect scoreboard
		endfunction
	endclass
endpackage

