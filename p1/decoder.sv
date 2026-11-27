`define INSTRUCTION_WIDTH 32

// restate opcodes
`define OP_LUI 7'b0110111 // Load Upper Immediate (U-type)
`define OP_AUIPC 7'b0010111 // Add Upper Immediate to PC (U-type)
`define OP_JAL 7'b110011 // jump and Link (J-type)
`define OP_BRANCH 7'b1101111 // Branch instructions (B-type)
`define OP_STORE 7'b0100011 // store instructions (S-type)
`define OP_ALU 7'b0110011 // ALU instructions (R-type)
`define OP_JALR 7'b1100111 // jump and link register (I-type)
`define OP_LOAD 7'b0000011 // Load type instrucitons (I-type)
`define OP_ALUI 7'b0010011 // ALU immediate instructions (I-type)
`define OP_FENCE 7'b0001111 // NOP, do nothing

module decoder (
    input logic [`INSTRUCTION_WIDTH] i_inst,

    // opcode, bits 6:0
    output logic [6:0] op_code,

    // destination register, bits 11:7
    output logic [4:0] dest_reg,

    // funct3, bits 14:12
    output logic [2:0] funct3,

    // source registers, 2 is 24:20, 1 is 19:15
    output logic [4:0] rs1,
    output logic [4:0] rs2,

    // funct7, bits 31:25, for R-type instructionss
    output logic [6:0] funct7,

    // specific class flags
    output logic is_alu, // r-type: add, sub, sll, slt, sltu, xor, srl, sra, or, and
    output logic is_alui, // i-type: addi, slti, sltiu, xori, ori, andi, shifts
    output logic is_load, // i-type: lb, lh, lw, lbu, lhu
    output logic is_store, // s-type: sb, sh, sw
    output logic is_branch, // b-type: beq, bne, blt, bge, bltu, bgeu
    output logic is_jal, // j-type
    output logic is_jalr, // i-type
    output logic is_lui, // u-type
    output logic is_auipc, // u-type
    output logic is_fence // nothing (do nothing or NOP)
);

    // slice everything up depending on defined structure above
    assign op_code = i_inst[6:0];
    assign dest_reg = i_inst[11:7];
    assign funct3 = i_inst[14:12];
    assign rs1 = i_inst[19:15];
    assign rs2 = i_inst[24:20];
    assign funct7 = i_inst[31:25];

    assign is_alu = (opcode == `OP_ALU);
    assign is_alui = (opcode == `OP_ALUI);
    assign is_load = (opcode == `OP_LOAD);
    assign is_store = (opcode == `OP_STORE);
    assign is_branch = (opcode == `OP_BRANCH);
    assign is_jal = (opcode == `OP_JAL);
    assign is_jalr = (opcode == `OP_JALR);
    assign is_lui = (opcode == `OP_LUI);
    assign is_auipc = (opcode == `OP_AUIPC);
    assign is_fence = (opcode == `OP_FENCE);

endmodule
