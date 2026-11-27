// instantiate and connect every block

module top #(
    parameter IMEM_INIT_FILE_PREFIX = "",
    parameter CLK_FREQ = 12000000
)(
    input logic clk,
    input logic rst,

    output logic LED,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);
    // the very start of insruction memory
    localparam [31:0] PC_RESET = 32'h00001000;

    // Initialize program counter
    logic [31:0] pc = PC_RESET;

    // initialize instruction register
    logic [31:0] ir = 32'd0;

    // intialize the alu result register
    logic [31:0] alu_reg = 32'd0;

    // the instruction address after the current one
    logic [31:0] pc_plus4;

    // the address the pc loads next. depends on branch
    logic [31:0] nextpc;

    logic [31:0] imem_data_out;
    logic [31:0] dmem_data_out;

    // sign extended immediate from imm gen
    logic [31:0] imm;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    // alu operands and respective result
    logic[31:0] alu_a;
    logic[31:0] alu_b;
    logic[31:0] alu_out;

    // value written into dest_reg from writeback
    logic [31:0] wb_data;

    // branch taken or jump?
    logic branch_taken;

    // decoder outputs
    logic [4:0] dest_reg;
    logic [2:0] funct3;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [6:0] funct7;

    // class flags / decoder outputs
    logic is_alu; // r-type: add, sub, sll, slt, sltu, xor, srl, sra, or, and
    logic is_alui; // i-type: addi, slti, sltiu, xori, ori, andi, shifts
    logic is_load; // i-type: lb, lh, lw, lbu, lhu
    logic is_store; // s-type: sb, sh, sw
    logic is_branch; // b-type: beq, bne, blt, bge, bltu, bgeu
    logic is_jal; // j-type
    logic is_jalr; // i-type
    logic is_lui; // u-type
    logic is_auipc; // u-type
    logic is_fence; // nothing (do nothing or NOP)

    // pwm values for leds
    logic pwm_LED;
    logic pwm_RED;
    logic pwm_GREEN;
    logic pwm_BLUE;

    // control unit outputs
    logic ir_write;
    logic pc_write;
    logic alu_src_a;
    logic alu_src_b;
    logic [5:0] alu_op;
    logic branch;
    logic [2:0] branch_opcode;
    logic [1:0] result_mux; // 00 = ALU result, 01 = PC+4 and return address, 10 = data mem read
    logic reg_write;
    logic mem_write; // indicates whether to store to data memory or not

    assign pc_plus4 = pc + 32'd4;
    assign next_pc = branch_taken ? {alu_out[31:1], 1'b0} : pc_plus4;

    // update pc register
    always_ff @(posedge clk) begin
        if (rst)
            pc <= PC_RESET;
        else if (pc_write)
            pc <= next_pc;
    end

    // instruction register
    always_ff @(posedge clk) begin
        if (ir_write)
            ir <= imem_data_out;
    end

    // alu result register
    always_ff @(posedge clk) begin
        alu_reg <= alu_out;
    end

    // alu operand a
    always_comb begin
        case (alu_src_a)
            2'b00: alu_a = rs1_data;
            2'b01: alu_a = pc;
            2'b10: alu_a = 32'd0;
            default: alu_a = rs1_data;
        endcase
    end

    // alu operand b
    assign alu_b = alu_src_b ? imm : rs2_data;

    // writeback mux
    always_comb begin
        case (result_mux)
            2'b00: wb_data = alu_reg;
            2'b01: wb_data = pc_plus4;
            2'b10: wb_data = dmem_data_out;
            default: wb_Data = alu_reg;
        endcase
    end

    assign LED = ~pwm_LED;
    assign RGB_R = ~pwm_RED;
    assign RGB_G = ~pwm_GREEN;
    assign RGB_B = ~pwm_BLUE;

    // decoder instance
    decoder u_decoder(
        .i_inst (ir),
        .op_code (),
        .dest_reg (dest_reg)
    )

endmodule
