`timescale 1ns/1ns

`define REG_FILE    uut_ID_stage.u_register_file.mem

`define F3_SLLI     3'b001
`define F3_SRAI     3'b101
`define F3_SRLI     3'b101

module tb_ID_stage;

    localparam PC_RESET_VALUE = 32'h0;
    localparam CLK_FREQ       = 50_000_000;
    localparam CLK_PERIOD     = 1_000_000_000 / CLK_FREQ;

    //Global Signal
    reg   clk;
    reg   n_rst;

    //From Control Unit
    reg           RegWrite;
    reg   [2:0]   Imm_Src;

    //From Instruction Memory
    reg   [31:0]  instr;

    //From IF stage
    reg   [31:0]  curr_pc_in;
    reg   [31:0]  pc_plus_4_in;

    //From WB stage
    reg   [31:0]  reg_wdata;

    //ID stage out
    wire  [31:0] RD1;
    wire  [31:0] RD2;
    wire  [31:0] imm_value;
    wire  [31:0] curr_pc_out;
    wire  [31:0] pc_plus_4_out;

    //UUT instance
    ID_stage uut_ID_stage(
        .clk    (clk),
        .n_rst  (n_rst),

        .RegWrite   (RegWrite),
        .Imm_Src    (Imm_Src),

        .instr          (instr),
        .curr_pc_in     (curr_pc_in),
        .pc_plus_4_in   (pc_plus_4_in),
        .reg_wdata      (reg_wdata),

        .RD1            (RD1),
        .RD2            (RD2),
        .imm_value      (imm_value),
        .curr_pc_out    (curr_pc_out),
        .pc_plus_4_out  (pc_plus_4_out)
    );

    //Clock & Reset init
    initial begin
        clk = 1'b0;
        n_rst = 1'b0;
        #7; n_rst = 1'b1;
    end

    always #(CLK_PERIOD/2) clk = ~clk;

    //Task Global Variables
    integer test_instr;
    integer test_rs1;
    integer test_rs2;
    integer test_rd1;
    integer test_rd2;
    integer test_rd;
    integer test_rd_wdata;
    integer test_imm_value;

    task reg_file_init;
    begin
        integer idx;
        for(idx = 0; idx < 32; idx = idx + 1)begin
            `REG_FILE[idx] = 0;
        end
    end
    endtask

    //Register File Verifying task
    //read task
    task reg_file_read;
    begin
        //initialize register file
        reg_file_init;
        
        //assign random data
        test_rd     = $urandom_range(0, 31);
        test_rs1    = $urandom_range(0, 31);
        test_rs2    = $urandom_range(0, 31);   
        test_rd1    = $urandom;
        test_rd2    = $urandom;
        test_instr  = {7'h0, test_rs2[4:0], test_rs1[4:0], 3'h0, test_rd[4:0], 7'h0};

        //exception handler 1. (reading same address)
        if((test_rs1 == test_rs2) && (test_rd1 != test_rd2))
            test_rd1 = test_rd2;

        //write random data into register file
        `REG_FILE[test_rs1[4:0]] = test_rd1;
        `REG_FILE[test_rs2[4:0]] = test_rd2;

        //test start
        repeat(2) @(negedge clk);
        RegWrite    = 1'b0;
        instr       = test_instr;

        //check result
        @(negedge clk);
        if(test_rs1[4:0] == 0 && RD1 == 0)
            $display("RD1 READ PASS!");
        
        if(test_rs2[4:0] == 0 && RD2 == 0)
            $display("RD2 READ PASS!");

        if(RD1 == test_rd1)
            $display("RD1 READ PASS!");
        
        if(RD2 == test_rd2)
            $display("RD2 READ PASS!");
        
        if(test_rs1[4:0] != 0 && RD1 != test_rd1)begin
            $display("RD1 READ FAIL..");
            $finish;
        end
        
        if(test_rs2[4:0] != 0 && RD2 != test_rd2)begin
            $display("RD2 READ FAIL..");
            $finish;
        end
    end
    endtask

    //write task
    task reg_file_write;
    begin
        //initialize register file
        reg_file_init;
        RegWrite = 1'b0;

        //assign random data
        test_rd     = $urandom_range(0, 31);
        test_rs1    = 32'h0;
        test_rs2    = 32'h0;   
        test_rd1    = $urandom;
        test_rd2    = $urandom;
        test_instr  = {7'h0, test_rs2[4:0], test_rs1[4:0], 3'h0, test_rd[4:0], 7'h0};
        test_rd_wdata = $urandom;

        //register file write
        repeat(2) @(negedge clk);
        RegWrite = 1'b1;
        instr = test_instr;
        reg_wdata = test_rd_wdata;

        //release write trigger
        @(negedge clk);
        RegWrite = 1'b0;
        instr = 32'h33;
        reg_wdata = 32'h0;

        //check result
        repeat(2) @(negedge clk);
        if(test_rd == 0)
            $display("REG WRITE PASS!");
        
        else if(`REG_FILE[test_rd[4:0]] == test_rd_wdata)
            $display("REG WRITE PASS!");
        
        else begin
            $display("REG WRITE FAIL..");
            $finish;
        end
    end
    endtask

    //extend logic test
    //I-type extned
    task ext_i_type;
        reg [31:0] answer;
    begin
        //uimm extend test 1 
        test_imm_value = $urandom;
        test_instr = {test_imm_value[11:0], 5'b0, `F3_SLLI, 5'b0, 7'b0};
        answer = {27'h0, test_imm_value[4:0]};

        repeat(2) @(negedge clk);
        Imm_Src = 3'b000;
        instr   = test_instr;

        @(negedge clk);
        if(answer == imm_value)
            $display("I-TYPE uimmExt 1 PASS!");
        
        else begin
            $display("I-TYPE uimmExt 1 FAIL..");
            $finish;
        end

        //uimm ext test 2
        test_imm_value = $urandom;
        test_instr = {test_imm_value[11:0], 5'b0, `F3_SRAI, 5'b0, 7'b0};
        answer = {27'h0, test_imm_value[4:0]};

        repeat(2) @(negedge clk);
        Imm_Src = 3'b000;
        instr   = test_instr;

        @(negedge clk);
        if(answer == imm_value)
            $display("I-TYPE uimmExt 2 PASS!");
        
        else begin
            $display("I-TYPE uimmExt 2 FAIL..");
            $finish;
        end

        //signed ext test
        test_imm_value = $urandom;
        test_instr = {test_imm_value[11:0], 5'b0, 3'b000, 5'b0, 7'b0};
        answer = {{27{test_imm_value[11]}}, test_imm_value[11:0]};

        repeat(2) @(negedge clk);
        Imm_Src = 3'b000;
        instr   = test_instr;

        @(negedge clk);
        if(answer == imm_value)
            $display("I-TYPE SignExt PASS!");
        
        else begin
            $display("I-TYPE SignExt FAIL..");
            $finish;
        end
    end
    endtask

    //S-type extend
    task ext_s_type;
        reg [31:0] answer;
    begin
        test_imm_value = $urandom;
        test_instr = {test_imm_value[11:5], 5'b0, 5'b0, 3'b0, test_imm_value[4:0], 7'b0};
        answer = {{20{test_imm_value[11]}}, test_imm_value[11:0]};

        repeat(2) @(negedge clk);
        Imm_Src = 3'b001;
        instr   = test_instr;

        @(negedge clk);
        if(answer == imm_value)
            $display("S-TYPE Ext PASS!");
        
        else begin
            $display("S-TYPE Ext FAIL..");
            $finish;
        end
    end
    endtask

    //B-type extend
    task ext_b_type;
        reg [31:0] answer;
    begin
        test_imm_value = $urandom;
        test_instr = {
            test_imm_value[12],
            test_imm_value[10:5], 
            5'b0,
            5'b0,
            3'b0,
            test_imm_value[4:1],
            test_imm_value[11],
            7'b0
        };

        answer = {{20{test_imm_value[12]}}, test_imm_value[12:1], 1'b0};

        repeat(2) @(negedge clk);
        Imm_Src = 3'b010;
        instr   = test_instr;

        @(negedge clk);
        if(answer == imm_value)
            $display("B-TYPE Ext PASS!");
        
        else begin
            $display("B-TYPE Ext FAIL..");
            $finish;
        end
    end
    endtask

    //J-type extend
    task ext_j_type;
        reg [31:0] answer;
    begin
        test_imm_value = $urandom;
        test_instr = {
            test_imm_value[20],
            test_imm_value[10:1],
            test_imm_value[11],
            test_imm_value[19:12],
            5'b0,
            7'b0
        };

        answer = {{12{test_imm_value[20]}}, test_imm_value[20:1], 1'b0};

        repeat(2) @(negedge clk);
        Imm_Src = 3'b011;
        instr   = test_instr;

        @(negedge clk);
        if(answer == imm_value)
            $display("J-TYPE Ext PASS!");
        
        else begin
            $display("J-TYPE Ext FAIL..");
            $finish;
        end
    end
    endtask

    //U-type extend
    task ext_u_type;
        reg [31:0] answer;
    begin
        test_imm_value = $urandom;
        test_instr = {
            test_imm_value[31:12],
            5'b0,
            7'b0
        };

        answer = {test_imm_value[31:12], 12'h0};

        repeat(2) @(negedge clk);
        Imm_Src = 3'b100;
        instr   = test_instr;

        @(negedge clk);
        if(answer == imm_value)
            $display("U-TYPE Ext PASS!");
        
        else begin
            $display("U-TYPE Ext FAIL..");
            $finish;
        end
    end
    endtask

    //pass-through check
    task pass_through;
    begin
        curr_pc_in = $urandom;
        pc_plus_4_in = $urandom;

        @(negedge clk);

        if((curr_pc_in == curr_pc_out) && 
        (pc_plus_4_in == pc_plus_4_out))begin
            $display("PASS THROUGH PASS!");
        end

        else begin
            $display("PASS THROUGH FAIL..");
            $finish;
        end
    end
    endtask


    integer i;
    initial begin
        RegWrite        = 0;
        Imm_Src         = 0;
        instr           = 0;
        curr_pc_in      = 0;
        pc_plus_4_in    = 0;
        reg_wdata       = 0;

        for(i = 0; i < 1000; i = i + 1)begin
            $display("Test Count: %5d", i +1);
            reg_file_read();
            reg_file_write();
            ext_i_type();
            ext_s_type();
            ext_b_type();
            ext_j_type();
            ext_u_type();
            pass_through();
            $display("");
        end


        $display("\n");
        $display("########### ALL PASSED ###########");
        $display("\n");

        $finish;
    end

endmodule