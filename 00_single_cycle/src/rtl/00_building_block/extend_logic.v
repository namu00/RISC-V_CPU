module extend_logic(
    input   [31:0]    instr,      //Instruction
    input   [2:0]     imm_src,    //Imm_Src
    output  [31:0]    imm_extend  //Extended Value
);

    //opcode mapped localparam
    localparam OPC_LOAD = 7'b000_0011; //LOAD
    localparam OPC_STOR = 7'b010_0011; //STORE

    //Imm_Src mapped localparam
    localparam IMM_I    = 3'b000;   //I type imm_src
    localparam IMM_S    = 3'b001;   //S type imm_src
    localparam IMM_B    = 3'b010;   //B type imm_src
    localparam IMM_J    = 3'b011;   //J type imm_src
    localparam IMM_U    = 3'b100;   //U type imm_src

    //funct3 mapped localparam 
    localparam F3_SLLI  = 3'b001;
    localparam F3_SRxI  = 3'b101;

    reg [31:0] ext_value;

    wire [6:0]  opcode;
    wire [2:0]  funct3;
    wire        uimm_ext;

    assign opcode    = instr[6:0];
    assign funct3    = instr[14:12];


    assign uimm_ext = ( //using under 5bit
        (opcode != OPC_LOAD) &&
        (opcode != OPC_STOR) &&
        ((funct3 == F3_SLLI) || (funct3 == F3_SRxI))
    );

    always @(*)begin
        case(imm_src)
            IMM_I: begin
                if(uimm_ext)        //uimm extend (using under 5bit)
                    ext_value = {27'h0, instr[24:20]};

                else                //signed extend
                    ext_value = {{20{instr[31]}}, instr[31:20]};
            end

            IMM_S: begin //Address Extension
                ext_value = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            IMM_B: begin //Branch Target Address Extension
                ext_value = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            IMM_J: begin //Jump Target Address Extension
                ext_value = {{12{instr[31]}}, instr[31], instr[19:12], instr[20],instr[30:21], 1'b0};
            end

            IMM_U: begin //Upper Immediate Extension
                ext_value = {instr[31:12], 12'h0};
            end

            default: begin
                ext_value = 32'h0;
            end
        endcase
    end

    assign imm_extend = ext_value;

endmodule