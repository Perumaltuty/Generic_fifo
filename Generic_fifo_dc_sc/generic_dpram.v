//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Generic Dual-Port Synchronous RAM                           ////
////                                                              ////
////  This file is part of memory library available from          ////
////  http://www.opencores.org/cvsweb.shtml/generic_memories/     ////
////                                                              ////
////  Description                                                 ////
////  This block is a wrapper with common dual-port               ////
////  synchronous memory interface for different                  ////
////  types of ASIC and FPGA RAMs. Beside universal memory        ////
////  interface it also provides behavioral model of generic      ////
////  dual-port synchronous RAM.                                  ////
////  It also contains a fully synthesizeable model for FPGAs.    ////
////  It should be used in all OPENCORES designs that want to be  ////
////  portable accross different target technologies and          ////
////  independent of target memory.                               ////
////                                                              ////
////  Supported ASIC RAMs are:                                    ////
////  - Artisan Dual-Port Sync RAM                                ////
////  - Avant! Two-Port Sync RAM (*)                              ////
////  - Virage 2-port Sync RAM                                    ////
////                                                              ////
////  Supported FPGA RAMs are:                                    ////
////  - Generic FPGA (VENDOR_FPGA)                                ////
////    Tested RAMs: Altera, Xilinx                               ////
////    Synthesis tools: LeonardoSpectrum, Synplicity             ////
////  - Xilinx (VENDOR_XILINX)                                    ////
////  - Altera (VENDOR_ALTERA)                                    ////
////                                                              ////
////  To Do:                                                      ////
////   - fix Avant!                                               ////
////   - add additional RAMs (VS etc)                             ////
////                                                              ////
////  Author(s):                                                  ////
////      - Richard Herveille, richard@asics.ws                   ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.4  2002/09/28 08:18:52  rherveille
// Changed synthesizeable FPGA memory implementation.
// Fixed some issues with Xilinx BlockRAM
//
// Revision 1.3  2001/11/09 00:34:18  samg
// minor changes: unified with all common rams
//
// Revision 1.2  2001/11/08 19:11:31  samg
// added valid checks to behvioral model
//
// Revision 1.1.1.1  2001/09/14 09:57:10  rherveille
// Major cleanup.
// Files are now compliant to Altera & Xilinx memories.
// Memories are now compatible, i.e. drop-in replacements.
// Added synthesizeable generic FPGA description.
// Created "generic_memories" cvs entry.
//
// Revision 1.1.1.2  2001/08/21 13:09:27  damjan
// *** empty log message ***
//
// Revision 1.1  2001/08/20 18:23:20  damjan
// Initial revision
//
// Revision 1.1  2001/08/09 13:39:33  lampret
// Major clean-up.
//
// Revision 1.2  2001/07/30 05:38:02  lampret
// Adding empty directories required by HDL coding guidelines
//
//

//synopsys translate_off
//synopsys translate_on

`define VENDOR_FPGA
//`define VENDOR_XILINX
//`define VENDOR_ALTERA

module generic_dpram(
	// Generic synchronous dual-port RAM interface
	rclk, rrst, rce, oe, raddr, do,
	wclk, wrst, wce, we, waddr, di
);

	//
	// Default address and data buses width
	//
	parameter aw = 5;  // number of bits in address-bus
	parameter dw = 16; // number of bits in data-bus

	//
	// Generic synchronous double-port RAM interface
	//
	// read port
	input           rclk;  // read clock, rising edge trigger
	input           rrst;  // read port reset, active high
	input           rce;   // read port chip enable, active high
	input           oe;	   // output enable, active high
	input  [aw-1:0] raddr; // read address
	output [dw-1:0] do;    // data output

	// write port
	input          wclk;  // write clock, rising edge trigger
	input          wrst;  // write port reset, active high
	input          wce;   // write port chip enable, active high
	input          we;    // write enable, active high
	input [aw-1:0] waddr; // write address
	input [dw-1:0] di;    // data input

	//
	// Module body
	//





	//
	// Generic dual-port synchronous RAM model
	//

	//
	// Generic RAM's registers and wires
	//
	reg	[dw-1:0]	mem [(1<<aw)-1:0]; // RAM content
	reg	[dw-1:0]	do_reg;            // RAM data output register

	//
	// Data output drivers
	//
	assign do = (oe & rce) ? do_reg : {dw{1'bz}};

	// read operation
	always @(posedge rclk)
		if (rce)
          		do_reg <= #1 (we && (waddr==raddr)) ? {dw{1'b x}} : mem[raddr];

	// write operation
	always @(posedge wclk)
		if (wce && we)
			mem[waddr] <= #1 di;


	// Task prints range of memory
	// *** Remember that tasks are non reentrant, don't call this task in parallel for multiple instantiations.
	task print_ram;
	input [aw-1:0] start;
	input [aw-1:0] finish;
	integer rnum;
  	begin
    		for (rnum=start;rnum<=finish;rnum=rnum+1)
      			$display("Addr %h = %h",rnum,mem[rnum]);
  	end
	endtask



endmodule



