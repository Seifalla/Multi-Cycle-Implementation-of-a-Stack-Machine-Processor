`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Kentucky
// Engineer: Andrew Lee, Seif Moustafa
// 
// Create Date: 03/07/2017 10:15:06 AM
// Design Name: SIK Processor
// Module Name: processor
// Description: 
//////////////////////////////////////////////////////////////////////////////////

// Basic Defs
`define WORD	[15:0]
`define Opcode	[15:12]
`define Immed12 [11:0]
`define STATE	[3:0]
`define PRESIZE [3:0]
`define SPSIZE  [7:0]
`define REGSIZE [255:0]
`define MEMSIZE [65535:0]

//Opcodes (And state numbers)
`define OpALU   4'b1111
`define OpPre   4'b1000
`define OpCall  4'b1001
`define OpJump  4'b1010
`define OpJumpT 4'b1011
`define OpJumpF 4'b1100
`define OpRet   4'b1101
`define OpSys   4'b1110
`define OpDup   4'b0000
`define OpStore 4'b0001
`define OpLoad  4'b0010
`define OpGet   4'b0011
`define OpPush  4'b0100
`define OpPop   4'b0101
`define OpPut   4'b0110
`define OpADD   12'b01
`define OpSUB   12'b10
`define OpAND   12'b100
`define OpOR    12'b1000
`define OpXOR   12'b10000
`define OpLT    12'b100000
`define OpTEST  12'b1000000
`define START   4'b0111



module processor(halt, reset, clk);
    output reg halt;
    input reset, clk;
    reg `PRESIZE pre;
    //reg `WORD ir;
    reg `WORD regfile `REGSIZE;
    reg `WORD mainmem `MEMSIZE;
    reg `WORD pc;
    reg `WORD ir;
    reg `STATE s;
    reg `WORD source;
    reg `WORD dest;
    reg validpre;
    reg torf;
    reg `SPSIZE sp;
    reg start1;
    always @(reset)
    begin
        pc = 0;
        s = `START;
        halt = 0;
        sp = 0;
        start1 = 0;
        $readmemh0(mainmem);
    end
    
    always @(posedge clk)
    begin
        case(s)
            `START: 
            if(!start1) begin ir <= mainmem[pc]; start1 <= ~start1;  end
            else begin
                pc <= pc + 1;            // bump pc
                s <= ir`Opcode; // most instructions, state # is opcode
                start1 <= ~start1;
            end
            `OpALU: begin
               case(ir`Immed12)
               `OpADD: begin source = sp;
                dest = sp - 1;
                sp = dest;
                regfile[dest] = regfile[dest] + regfile[source];
               end
               `OpSUB: begin source = sp;
                  dest = sp - 1;
                  sp = dest;
                  regfile[dest] = regfile[dest] - regfile[source];
               end
               `OpAND: begin source = sp;
                  dest = sp - 1;
                  sp = dest;
                  regfile[dest] = regfile[dest] & regfile[source];
                  end
                `OpOR: begin source = sp;
                  dest = sp - 1;
                  sp = dest;
                  regfile[dest] = regfile[dest] | regfile[source];
                end
                `OpXOR: begin source = sp;
                  dest = sp - 1;
                  sp = dest;
                  regfile[dest] = regfile[dest] ^ regfile[source];
                 end
                 `OpLT: begin source = sp;
                   dest = sp - 1;
                   sp = dest;
                   regfile[dest] = regfile[source] < regfile[dest];
                  end
                 `OpTEST: begin source = sp;
                    dest = sp - 1;
                    sp = dest;
                    torf = (regfile[source] != 0);
                 end
               endcase
               s = `START; 
            end
            `OpPre: begin
                pre = ir `PRESIZE;
                validpre = 1;
                s = `START;
            end
            `OpCall: begin
                dest = sp + 1;
                sp = dest;
                regfile[dest] = pc + 1;
                if(validpre)
                begin
                    pc = {pre, ir`Immed12};
                    validpre = 0;
                end
                else
                    pc = {pc`Opcode, ir`Immed12};
                s = `START;
            end
            `OpJump: begin
                if(validpre)
                begin
                    pc = {pre, ir`Immed12};
                    validpre = 0;
                end
                else
                    pc = {pc`Opcode, ir`Immed12};
                s = `START;
             end
             `OpJumpT: begin
                if(torf)
                begin
                    if(validpre)
                    begin
                        pc = {pre, ir`Immed12};
                        validpre = 0;
                    end
                    else
                        pc = {pc`Opcode, ir`Immed12};
                end
                s = `START;
                end
               `OpJumpF: begin
                if(!torf)
                begin
                   if(validpre)
                   begin
                       pc = {pre, ir`Immed12};
                       validpre = 0;
                   end
                   else
                        pc = {pc`Opcode, ir`Immed12};
                end
                s = `START;
               end
            `OpRet: begin
                source = sp;
                sp = sp - 1;
                pc = regfile[source];
                s = `START;
            end
            `OpSys: begin
                // this does a bunch of things
                halt = 1; // kills program
            end
// added code
            `OpDup: begin
		dest = sp + 1;
		source = sp;
		sp = sp + 1;
		regfile[dest] = regfile[source];
		s = `START;
	     end
	     `OpStore: begin
		dest = sp - 1;
		source = sp;
		sp = sp - 1;
		mainmem[regfile[dest]] = regfile[source];
		regfile[dest] = regfile[source];
		s = `START;
	     end
	     `OpLoad: begin
		dest = sp;
		regfile[dest] = mainmem[regfile[dest]];
		s = `START;
	     end
	     `OpGet: begin
		dest = sp + 1;
		source = sp - ir `Immed12;
		sp = sp + 1;
		regfile[dest] = regfile[source];
		s = `START;
	     end
	     `OpPop: begin
		sp = sp - ir `Immed12;
		s = `START;
	     end
	     `OpPut: begin
		dest = sp - ir `Immed12;
		source = sp;
		regfile[dest] = regfile[source];
		s = `START;
	     end
	     `OpPush: begin
		dest = sp + 1;
                sp = sp + 1;
		if(validpre)
                begin
                    regfile[dest] = {pre, ir`Immed12};
                    validpre = 0;
                end
                else
                    regfile[dest] = {pc`Opcode, ir`Immed12};
		s = `START;
	     end
	    default: halt = 1;
        endcase
    end
    
endmodule

module testbench;
reg reset = 0;
reg clk = 0;
wire halted;
processor PE(halted, reset, clk);
initial begin
  $dumpfile;
  $dumpvars(0, PE);
  #10 reset = 1;
  #10 reset = 0;
  while (!halted) begin
    #10 clk = 1;
    #10 clk = 0;
  end
  $finish;
end
endmodule
