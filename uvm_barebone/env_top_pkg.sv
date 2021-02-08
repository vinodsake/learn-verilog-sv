/**********************************************************************
* File Name	: env_top_pkg.sv
* Description 	: Top env pkg
* Creation Date : 07-02-2021
* Last Modified : Sun 07 Feb 2021 11:51:29 PM PST
* Author 	: Vinod Sake
* Email 	: vinodsake042@gmail.com
* GitHub	: github.com/vinodsake
**********************************************************************/

package env_top_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
import env_1_pkg::*;
import env_2_pkg::*;

	class env_top extends uvm_env;
		`uvm_component_utils(env_top)
		env_1 m_env_1;
		env_2 m_env_2;
		
		function new(string name = "env_top",uvm_component parent = "");
			super.new(name,parent);
		endfunction

		function void build_phase(uvm_phase phase);
			m_env_1 = env_1::type_id::create("m_env_1");
			m_env_2 = env_2::type_id::create("m_env_2");
		endfunction

		function 
	endclass
endpackage
