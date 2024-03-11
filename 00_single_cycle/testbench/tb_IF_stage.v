`timescale 1ns/1ns

module tb_IF_stage;

    localparam PC_RESET_VALUE = 32'h0;
    localparam CLK_FREQ       = 50_000_000;
    localparam CLK_PERIOD     = 1_000_000_000 / CLK_FREQ;

    //Global Signal
    reg clk;
    reg n_rst;

    //From Control Unit
    reg [1:0] PC_src;
    
    //PC mux input
    reg [31:0] next_pc;
    reg [31:0] jump_pc;
    reg [31:0] branch_pc;

    //Current PC & PC + 4 out
    wire [31:0] curr_pc;
    wire [31:0] pc_plus_4;

    //UUT instance
    IF_stage #(
        .PC_RESET_VALUE (PC_RESET_VALUE)
    )uut_IF_stage(
        .clk    (clk),
        .n_rst  (n_rst),

        .PC_src     (PC_src),

        .next_pc    (next_pc),
        .jump_pc    (jump_pc),
        .branch_pc  (branch_pc),

        .curr_pc    (curr_pc),
        .pc_plus_4  (pc_plus_4)
    );

    //Clock & Reset init
    initial begin
        clk = 1'b0;
        n_rst = 1'b0;
        #7; n_rst = 1'b1;
    end

    always #(CLK_PERIOD/2) clk = ~clk;


    //task variable
    integer random_pc_src;
    integer random_next_pc;
    integer random_jump_pc;
    integer random_branch_pc;
    integer error;

    //verifying task
    task IF_stage_check;
    begin
        error = 0;
        repeat(2) @(negedge clk);

        //assign test values
        random_pc_src = $urandom_range(0, 2);
        random_next_pc = $random;
        random_jump_pc = $random;
        random_branch_pc = $random;

        PC_src = random_pc_src;
        next_pc = random_next_pc;
        jump_pc = random_jump_pc;
        branch_pc = random_branch_pc;

        //wait next cycle
        @(negedge clk);

        //value check
        $display("PC_src value: %x", PC_src);

        if(PC_src == 2'b00)begin
            if(curr_pc != next_pc)begin
                $display("PC MUX FAIL");
                error = 1;
            end


            if(pc_plus_4 != (next_pc + 4))begin
                $display("PC + 4 FAIL");
                error = 1;
            end
        end

        if(PC_src == 2'b01)begin
            if(curr_pc != jump_pc)begin
                $display("PC MUX FAIL");
                error = 1;
            end


            if(pc_plus_4 != (jump_pc + 4))begin
                $display("PC + 4 FAIL");
                error = 1;
            end
        end

        if(PC_src == 2'b10) begin
            if(curr_pc != branch_pc)begin
                $display("PC MUX FAIL");
                error = 1;
            end


            if(pc_plus_4 != (branch_pc + 4))begin
                $display("PC + 4 FAIL");
                error = 1;
            end
        end


        if(error == 0)
            $display("### PASSED!");

        if(error != 0) begin
            $display("--input--");
            $display("PC_src:    %x", PC_src);
            $display("next_pc:   %x", next_pc);
            $display("jump_pc:   %x", jump_pc);
            $display("branch_pc: %x", branch_pc);
            $display("--output--");
            $display("curr_pc:   %x", curr_pc);
            $display("pc_plus_4: %x", pc_plus_4);
        end

        $display("\n");

    end
    endtask

    //testvector
    integer i;
    initial begin
        for(i = 0; i < 1000; i = i + 1)begin
            IF_stage_check();
        end

        $finish;
    end

    `ifdef FSDB
        initial begin
            $fsdbDumpvars(0);
            $fsdbDumpfile("test.fsdb");
        end
    `endif
endmodule