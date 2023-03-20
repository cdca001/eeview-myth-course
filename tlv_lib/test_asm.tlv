\m4_TLV_version 1d: tl-x.org
m4_define(['m4_test_asm'],
 ['m4_asm(ADD, r10, r0, r0)             // Initialize r10 (a0) to 0.
   // Function:
   m4_asm(ADD, r14, r10, r0)            // Initialize sum register a4 with 0x0
   m4_asm(ADDI, r12, r10, 1010)         // Store count of 10 in register a2.
   m4_asm(ADD, r13, r10, r0)            // Initialize intermediate sum register a3 with 0
   // Loop:
   m4_asm(ADD, r14, r13, r14)           // Incremental addition
   m4_asm(ADDI, r13, r13, 1)            // Increment intermediate register by 1
   m4_asm(BLT, r13, r12, 1111111111000) // If a3 is less than a2, branch to label named <loop>
   m4_asm(ADD, r10, r14, r0)            // Store final result to register a0 so that it can be read by main program   
   m4_asm(JAL, r17, 0000000000001110)
   m4_asm(ADDI, r1, r0, 0100) //r1=4
   m4_asm(ADDI, r2, r0, 0011) //r2=3
   m4_asm(ADDI, r3, r0, 0010) //r3=2
   m4_asm(ADDI, r4, r0, 0001) //r4=1
   m4_asm(JAL, r0, 0000000000001010) //jump to end
   m4_asm(ADDI, r15, r0, 1010) //this should not be executed
   //load/store test:
   m4_asm(SW, r0, r10, 100)
   m4_asm(LW, r15, r0, 100)
   m4_asm(JALR, r0, r17, 0) //return 
   //end:
   m4_asm(ADDI, r16, r0, 1010)
   m4_asm(ADD, r0, r0, r0) //NOP
   m4_asm(ADD, r0, r0, r0) //NOP
   m4_asm(ADD, r0, r0, r0) //NOP
   m4_asm(ADD, r0, r0, r0) //NOP 
   '])
