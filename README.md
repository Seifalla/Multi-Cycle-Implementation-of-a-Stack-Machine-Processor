# Multi-Cycle-Implementation-of-a-Stack-Machine-Processor

Abstract—This project required students to create a multicycle processor that implements the Stacking In Kentucky (SIK) 
Instruction Set. SIK is logically complete, but lacks any floating point operations and, as a 
stack machine, has some efficiency drawbacks.
I.INTRODUCTION
The slowest, but most fundamental processor to design is a multicycle machine. 
This machine executes instructions in a variable number of clock cycles. The group implemented a multicycle processor 
in verilog for the Stacking In Kentucky (SIK) instruction set. SIK is a fairly generic stack instruction set that 
allows a wide variety of applications. The processor has 16-bit instructions, 256 16-bit stack registers, and assumes
64KB of memory.
II. INSTRUCTION ENCODING
The team initialized memory using “$readmemh0()” to load programs onto the processor. Instructions were encoded using
the AIK tool. The 4-bit opcodes also provide the state numbers for the machine’s control logic. One convenient feature 
of the encoding scheme is that all ALU operations share the “1111” opcode, then use a 1-hot encoding in the 
immediate field to determine which operation is being executed on the stack variables.
Some instructions require a 16-bit immediate field. For these instructions, the assembler encodes a “pre” instruction 
with the top 4 bits. The processor places these in a special 4- bit register and uses the register on the next instruction 
that requires a “pre” value.
III. IMPLEMENTATION
The group implemented the processor in a single module. While this is not always advisable, the nature of the 
operations allowed this to work effectively. The “`define” directive was used to set the state and opcode values 
and the sizes for registers, memory, and words. This means that the processor could be readily converted to a different
instruction-encoding scheme or even a larger word size. Upon reset, the processor sets its state to “START”, 
its PC and other special registers (such as pre) to 0, and loads the program into memory. Because there was only 
one free 4-bit code to give a START state, the team added a 1-bit register to track whether the START was loading 
the IR or incrementing the PC and beginning the operation. A “magic” register may not be the cleanest solution, but it was 
effective.
The operations the processor supports are all parts of “case” statements with the state/opcode as the switch variable. 
Each operation executes as directed in the SIK instruction specification.
IV. TESTING AND VERIFICATION
Our testing procedure mainly relied on the idea of halting the program early if it failed the test. 
For example, if the sum of 4 and 2 is not equal to 6, we used a conditional jump and a system call to terminate the program. 
To ensure that this testing method works, we compared the output to an erroneous number, in which case the program 
halted earlier than it should have, as expected.
To test an instruction, we wrote a program that executes it and then we compared the output with the expected output 
using an Xor (since Xor’ing a number with itself results in a 0). We used the Test instruction to check if the output 
of the Xor is 0. Then, we used a JumpF to skip the Sys call if the output is 0 (since JumpF jumps if the value of the 
“torf” register is 0). we used this method to test the ALU instructions, Load, Store, and Push. To test the Pop 
instruction, we pushed some values onto the stack. Then, we used Pop and verified that the stack pointer 
is decremented by 1. To test the Pop instruction, I pushed some values onto the stack. Then, we used Pop and verified 
that the stack pointer is decremented by 1. To test the Call and Ret instructions, we used Call to jump to a label. 
Then, at the end of the function, we used Ret to jump back to the where we were. we put a System call after Ret to verify 
that it returns correctly. Since the Pre instruction is not visible to the user, we tested it by pushing an
out-of-range value onto the stack (i.e 10000). We know that we have complete line coverage because we tested every 
operation at least once, covering every condition and case statement.
