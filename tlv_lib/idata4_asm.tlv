\m4_TLV_version 1d: tl-x.org
m4_define(['m4_idata4_asm'],
 ['m4_asm(ADD, r2, r0, r0)
  m4_asm(ADD, r8, r0, r0)
  m4_asm(SW, r2, r8, 101100)
  m4_asm(ADDI, r8, r2, 110000)
  m4_asm(ADDI, r15, r0, 10)
  m4_asm(SW, r8, r15, 111111011000)
  m4_asm(ADDI, r15, r0, 0011)
  m4_asm(SW, r8, r15, 111111011100)
  m4_asm(LW, r15, r8, 111111011100)
  m4_asm(SW, r8, r15, 111111101100)
  m4_asm(ADDI, r15, r0, 000001100001)
  m4_asm(SB, r8, r15, 111111101011)
  m4_asm(LBU, r15, r8, 111111101011)
  m4_asm(SB, r8, r15, 111111101010)
  m4_asm(ADDI, r15, r0, 1010)
  m4_asm(SH, r8, r15, 111111101000)
  m4_asm(LHU, r15, r8, 111111101000)
  m4_asm(SH, r8, r15, 111111011100)
  m4_asm(ADDI, r0, r0, 0)
  m4_asm(LW, r8, r2, 000000101100)
  m4_asm(JAL, r0, 0)'])
