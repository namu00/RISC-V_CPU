`timescale 1ns/1ns

module IF_stage#(
    parameter PC_RESET_VALUE = 32'h0
)(
    //Global Signal
    input   clk,
    input   n_rst,
    
    //From Control Unit
    input   [1:0]   PC_src,

    //PC mux input
    input   [31:0]  next_pc,
    input   [31:0]  jump_pc,
    input   [31:0]  branch_pc,

    //Current PC & PC + 4 out
    output  [31:0]  curr_pc,
    output  [31:0]  pc_plus_4
);

    //PC mux & PC FF variable
    reg [31:0]  PC;
    reg [31:0]  PC_reg;

    //output assignment
    assign curr_pc      =   PC_reg;   

    //PC_mux
    always @(*)begin
        case(PC_src)
            2'b00:      PC = next_pc;
            2'b01:      PC = jump_pc;
            2'b10:      PC = branch_pc;
            default:    PC = PC_RESET_VALUE;
        endcase 
    end

    //PC_FF
    always @(posedge clk or negedge n_rst)begin
        if(!n_rst)
            PC_reg <= PC_RESET_VALUE;
        else
            PC_reg <= PC;
    end

    //PC + 4 logic
    pc_prefix_adder u_pc_plus_4(
        .curr_pc    (PC_reg),
        .pc_plus_4  (pc_plus_4)
    );      

endmodule