\m4_TLV_version 1d: tl-x.org
m4_define(['m4_idata3'],
 ['m4_asm(ADDI, r10, r0, 0)
  m4_asm(ADDI, r11, r0, 100)
  m4_asm(ADDI, r12, r0, 111100)
  m4_asm(ADDI, r13, r0, 1010)
  m4_asm(SW, r10, r12, 100)
  m4_asm(SW, r11, r13, 1000)
  m4_asm(LW, r14, r10, 100)
  m4_asm(LW, r15, r11, 1000)
  m4_asm(ADD, r16, r12, r13)
  m4_asm(ADD, r17, r15, r14)
  m4_asm(SUB, r6, r16, r17)
  m4_asm(JAL, r0, 0)'])
