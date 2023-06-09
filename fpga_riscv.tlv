\m4_TLV_version 1d -p verilog --bestsv --noline: tl-x.org
//\m4_TLV_version 1d: tl-x.org
//change first line to this if working on fpga (recommended by Bala)
//\m4_TLV_version 1d -p verilog --bestsv --noline: tl-x.org
\SV
   // This code can be found in: https://github.com/stevehoover/RISC-V_MYTH_Workshop
   
   // Use Bala lib.tlv if working on fpga
   m4_include_lib(['https://raw.githubusercontent.com/BalaDhinesh/RISC-V_MYTH_Workshop/master/tlv_lib/risc-v_shell_lib.tlv'])
   //m4_include_lib(['https://raw.githubusercontent.com/cdca001/eeview-myth-course/main/tlv_lib/risc-v_shell_lib.tlv'])

\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV
   //test sum of numbers from 1 to 9 
   //m4_test_asm
   //idata1.asm - confirmed working
   //m4_idata1_asm
   //idata2.asm - tested - confirmed working
   //m4_idata2_asm
   //idata3.asm - issue when 2 consecutive loads solved - confirmed working
   //m4_idata3_asm
   //idata4.asm - tested - confirmed working
   //m4_idata4_asm
   //m4_asm(ADD, r0, r0, r0)
   //m4_asm(LW, r10, r0, 100)
   //m4_asm(SW, r0, r10, 100)
   //m4_asm(ADDI, r10, r0, 1100)
   //m4_asm(JAL, r0, 0)
      
   m4_define_hier(['M4_IMEM'], M4_NUM_INSTRS)

   |cpu
      @0
         $reset = *reset;
         //$start = (>>1$reset==1'b1 && $reset==1'b0) ? 1'b1 : 1'b0;
         //$valid = $reset ? 0 : 
         //         $start ? 1'b1 :
         //         >>3$valid;
         $pc[31:0] = (>>1$reset) ? 32'b0 : 
                     (>>3$valid_taken_br || (>>3$valid_jump && >>3$is_jal)) ? >>3$br_tgt_pc :
                     (>>3$valid_load_redir) ? >>3$inc_pc :
                     (>>3$valid_jump && >>3$is_jalr) ? >>3$jalr_tgt_pc :
                      >>1$inc_pc;
         $imem_rd_en = !$reset;
         $imem_rd_addr[31:0] = $pc/4;

      @1
         //*passed = |cpu/xreg[10]>>5$value == (1+2+3+4+5+6+7+8+9);
         //*passed = |cpu/xreg[16]>>5$value == (10);
         *passed = *cyc_cnt > 100;
         $inc_pc[31:0] = $pc + 4;
         
         $instr[31:0] = $imem_rd_data;
         
         $is_i_instr = $instr[6:2] ==? 5'b0000x ||
                       $instr[6:2] ==? 5'b001x0 ||
                       $instr[6:2] == 5'b11001 ||
                       $instr[6:2] == 5'b11100;
         $is_r_instr = $instr[6:2] == 5'b01011 ||
                       $instr[6:2] == 5'b01100 ||
                       $instr[6:2] == 5'b01110 ||
                       $instr[6:2] == 5'b10100;
         $is_s_instr = $instr[6:2] ==? 5'b0100x;
         $is_j_instr = $instr[6:2] == 5'b11011;
         $is_b_instr = $instr[6:2] == 5'b11000;
         $is_u_instr = $instr[6:2] ==? 5'b0x101;
         $imm[31:0] = $is_i_instr ? {{21{$instr[31]}}, $instr[30:20]} :
                      $is_s_instr ? {{21{$instr[31]}}, $instr[30:25], $instr[11:8], $instr[7]} :
                      $is_b_instr ? {{20{$instr[31]}}, $instr[7], $instr[30:25], $instr[11:8], 1'b0} :
                      $is_u_instr ? {$instr[31:12], 12'b0} :
                      $is_j_instr ? {{12{$instr[31]}}, $instr[19:12], $instr[20], $instr[30:25], $instr[24:21], 1'b0} :
                      0;
         $opcode[6:0] = $instr[6:0];
         $rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr;
         ?$rs2_valid
            $rs2[4:0] = $instr[24:20];
         $rs1_valid = $is_r_instr || $is_s_instr || $is_b_instr || $is_i_instr;
         ?$rs1_valid
            $rs1[4:0] = $instr[19:15];
            $funct3[2:0] = $instr[14:12];
         $rd_valid = $is_r_instr || $is_u_instr || $is_j_instr || $is_i_instr;
         ?$rd_valid
            $rd[4:0] = $instr[11:7];
         $funct7_valid = $is_r_instr;
         ?$funct7_valid
            $funct7[6:0] = $instr[31:25];
            
         $dec_bits[10:0] = {$funct7[5], $funct3, $opcode};
         $is_beq = $dec_bits ==? 11'bx_000_1100011;
         $is_bne = $dec_bits ==? 11'bx_001_1100011;
         $is_blt = $dec_bits ==? 11'bx_100_1100011;
         $is_bge = $dec_bits ==? 11'bx_101_1100011;
         $is_bltu = $dec_bits ==? 11'bx_110_1100011;
         $is_bgeu = $dec_bits ==? 11'bx_111_1100011;
         $is_addi = $dec_bits ==? 11'bx_000_0010011;
         $is_add = $dec_bits ==? 11'b0_000_0110011;
         $is_jal = $dec_bits ==? 11'bx_xxx_1101111;
         $is_jalr = $dec_bits ==? 11'bx_000_1100111;
         $is_slti = $dec_bits ==? 11'bx_010_0010011;
         $is_sltiu = $dec_bits ==? 11'bx_011_0010011;
         $is_slt = $dec_bits ==? 11'b0_010_0110011;
         $is_sltu = $dec_bits ==? 11'b0_011_0110011;
         $is_xori = $dec_bits ==? 11'bx_100_0010011;
         $is_ori = $dec_bits ==? 11'bx_110_0010011;
         $is_andi = $dec_bits ==? 11'bx_111_0010011;
         $is_slli = $dec_bits ==? 11'b0_001_0010011;
         $is_srli = $dec_bits ==? 11'b0_101_0010011;
         $is_srai = $dec_bits ==? 11'b1_101_0010011;
         $is_sub = $dec_bits ==? 11'b1_000_0110011;
         $is_sll = $dec_bits ==? 11'b0_001_0110011;
         $is_xor = $dec_bits ==? 11'b0_100_0110011;
         $is_srl = $dec_bits ==? 11'b0_101_0110011;
         $is_sra = $dec_bits ==? 11'b1_101_0110011;
         $is_or = $dec_bits ==? 11'b0_110_0110011;
         $is_and = $dec_bits ==? 11'b0_111_0110011;
         $is_auipc = $dec_bits ==? 11'bx_xxx_0010111;
         $is_lui = $dec_bits ==? 11'bx_xxx_0110111;
         $is_lw = $dec_bits ==? 11'bx_010_0000011;
         $is_lhu = $dec_bits ==? 11'bx_101_0000011;
         $is_lbu = $dec_bits ==? 11'bx_100_0000011;
         $is_load = $is_lw || $is_lhu || $is_lbu;
         $is_sw = $dec_bits ==? 11'bx_010_0100011;
         $is_sh = $dec_bits ==? 11'bx_001_0100011;
         $is_sb = $dec_bits ==? 11'bx_000_0100011;
         $is_store = $is_sw || $is_sh || $is_sb;
         
         
      @2
         $rf_rd_en1 = $rs1_valid;
         $rf_rd_index1[4:0] = $rs1;
         $rf_rd_en2 = $rs2_valid;
         $rf_rd_index2[4:0] = $rs2;
         $src1_value[31:0] = ((>>1$rf_wr_en) && ($rs1 == >>1$rd)) ? >>1$result :
                             $rf_rd_data1;
         $src2_value[31:0] = ((>>1$rf_wr_en) && ($rs2 == >>1$rd)) ? >>1$result :
                             $rf_rd_data2;
         $br_tgt_pc[31:0] = $pc + $imm;
         $jalr_tgt_pc[31:0] = $src1_value + $imm;
         
      @3
         $valid = (!(>>1$valid_taken_br) && !(>>2$valid_taken_br)) && (!(>>1$is_load && !$is_load) && !(>>2$is_load && !$is_load)) && (!(>>1$taken_jump) && !(>>2$taken_jump));
         $valid_load_redir = ($valid && $is_load) && (!>>2$taken_br) && (!>>2$taken_jump);
         $valid_taken_br = ($valid && $taken_br) && (!>>2$is_load) && (!>>2$taken_jump);
         $valid_jump = ($valid && $taken_jump) && (!>>2$is_load) && (!>>2$taken_br);
         
         $result[31:0] = ($is_addi || $is_load || $is_store) ? $src1_value + $imm :
                         $is_add ? $src1_value + $src2_value :
                         $is_slti ? (($src1_value[31] == $imm[31]) ? ($src1_value < $imm) : {31'b0, $src1_value[31]}) :
                         $is_sltiu ? ($src1_value < $imm) :
                         $is_slt ? (($src1_value[31] == $src2_value[31]) ? ($src1_value < $src2_value) : {31'b0, $src1_value[31]}) :
                         $is_sltu ? ($src1_value < $src2_value) :
                         $is_andi ? ($src1_value & $imm) :
                         $is_ori ? ($src1_value | $imm) :
                         $is_xori ? ($src1_value ^ $imm) :
                         $is_slli ? ($src1_value << $imm[5:0]) :
                         $is_srli ? ($src1_value << $imm[5:0]) :
                         $is_and ? ($src1_value & $src2_value) :
                         $is_or ? ($src1_value | $src2_value) :
                         $is_xor ? ($src1_value ^ $src2_value) :
                         $is_sub ? ($src1_value - $src2_value) :
                         $is_sll ? ($src1_value << $src2_value[4:0]) :
                         $is_srl ? ($src1_value >> $src2_value[4:0]) :
                         $is_sra ? ({{32{$src1_value[31]}}, $src1_value} >> $src2_value[4:0]) :
                         $is_srai ? ({{32{$src1_value[31]}}, $src1_value} >> $imm[4:0]) :
                         $is_lui ? ({$imm[31:12], 12'b0}) :
                         $is_auipc ? ($pc + $imm) :
                         32'bx;      
         $taken_jump = $valid && ($is_jal || $is_jalr);
         $taken_br = ($is_beq && ($src1_value == $src2_value)) ||
                     ($is_bne && ($src1_value != $src2_value)) ||
                     ($is_blt && (($src1_value < $src2_value) ^ ($src1_value[31] != $src2_value[31]))) ||
                     ($is_bge && (($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31]))) ||
                     ($is_bltu && ($src1_value < $src2_value)) ||
                     ($is_bgeu && ($src1_value >= $src2_value));
         $rf_wr_en = $rd_valid && ($rd != 5'b00000) && $valid && (!$is_store) && (!$is_load) || (>>2$is_load);
         $rf_wr_index[4:0] = (>>2$is_load) ? >>2$rd :
                             $rd;
         $rf_wr_data[31:0] = (>>2$is_load) ? >>2$ld_data :
                             ($taken_jump) ? $inc_pc :
                             $result;
      @4
         $dmem_addr[31:0] = $result[31:0];
         $dmem_mode[1:0] = $is_sw || $is_lw ? 2'b11 :
                           $is_sh || $is_lhu ? 2'b10 :
                           $is_sb || $is_lbu ? 2'b01 :
                           2'b11;
         $dmem_rd_en = $is_load && $valid;
         $dmem_wr_en = $is_store && $valid;
         //$store_value[31:0] = $src2_value;
         $store_value[31:0] = ((>>3$is_load && $is_store) && (>>1$rd == >>1$rs2)) ? >>2$ld_data :
                              $src2_value;
         $dmem_wr_data[31:0] = $is_sw ? $store_value :
                               $is_sh ? {16'b0, $store_value[15:0]} :
                               $is_sb ? {24'b0, $store_value[7:0]} :
                               $store_value;
      @5
         $ld_data[31:0] = $is_lw ? $dmem_rd_data :
                          $is_lhu ? {16'b0, $dmem_rd_data[15:0]} :
                          $is_lbu ? {24'b0, $dmem_rd_data[7:0]} :
                          $dmem_rd_data;
      

      // Note: Because of the magic we are using for visualisation, if visualisation is enabled below,
      //       be sure to avoid having unassigned signals (which you might be using for random inputs)
      //       other than those specifically expected in the labs. You'll get strange errors for these.

   
   // Assert these to end simulation (before Makerchip cycle limit).
   //*passed = *cyc_cnt > 120;
   *failed = 1'b0;
   
   // Macro instantiations for:
   //  o instruction memory
   //  o register file
   //  o data memory
   //  o CPU visualization
   |cpu
      m4+imem(@1)    // Args: (read stage)
      m4+rf(@2, @3)  // Args: (read stage, write stage) - if equal, no register bypass is required
      m4+dmem(@4)    // Args: (read/write stage)
      m4+myth_fpga(@0)  // Uncomment to run on fpga

   m4+cpu_viz(@4)    // For visualisation, argument should be at least equal to the last stage of CPU logic. @4 would work for all labs.
\SV
   endmodule
