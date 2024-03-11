`timescale 1ns/1ns

module ID_stage(
    //Global Signal
    input   clk,
    input   n_rst,

    //From Control Unit
    input           RegWrite,
    input   [2:0]   Imm_Src,

    //From Instruction Memory
    input   [31:0]  instr,

    //From IF stage
    input   [31:0]  curr_pc_in,
    input   [31:0]  pc_plus_4_in,

    //From WB stage
    input   [31:0]  reg_wdata,

    //ID stage out
    output  [31:0] RD1,
    output  [31:0] RD2,
    output  [31:0] imm_value,
    output  [31:0] curr_pc_out,
    output  [31:0] pc_plus_4_out
);

    //register address
    wire [4:0] rs1  = instr[19:15];
    wire [4:0] rs2  = instr[24:20];
    wire [4:0] rd   = instr[11:7];

    //pass-through signals
    assign curr_pc_out      = curr_pc_in;
    assign pc_plus_4_out    = pc_plus_4_in;

    //register memory instance
    reg_file u_register_file(
        .clk        (clk),
        .we         (RegWrite),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd_addr    (rd),
        .rd_data    (reg_wdata),
        .rd1        (RD1),
        .rd2        (RD2)
    );

    //immediate value extend logic
    extend_logic u_extend_logic(
        .instr      (instr),
        .imm_src    (Imm_Src),
        .imm_extend (imm_value)
    );

endmodule