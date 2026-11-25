`define INSTRUCTION_WIDTH 32

// base set instruction opcodes
`define OP_LUI 7'b0110111 // Load Upper Immediate (U-type)
`define OP_AUIPC 7'b0010111 // Add Upper Immediate to PC (U-type)
`define OP_JAL 7'b110011 // jump and Link (J-type)
`define OP_BRANCH 7'b1101111 // Branch instructions (B-type)
`define OP_STORE 7'b0100011 // store instructions (S-type)
`define OP_ALU 7'b0110011 // ALU instructions (R-type)
`define OP_JALR 7'b1100111 // jump and link register (I-type)
`define OP_LOAD 7'b0000011 // Load type instrucitons (I-type)
`define OP_ALUI 7'b0010011 // ALU immediate instructions (I-type)

module sign_extension_unit (
    // 32 bit instruction received
    input logic [`INSTRUCTION_WIDTH-1:0] i_inst,

    // scrambled (sign extended) instruction
    output logic [`INSTRUCTION_WIDTH-1:0] o_imm_extended
);

    // define the opcode from the instruction
    logic [6:0] i_opcode = i_inst[6:0];

    always_comb begin

        // always 0 to avoid x cases
        o_imm_extended = '0;

        case (i_opcode)

            // U-type instructions inst[31:12], only 20-bit immediate field
            `OP_LUI, `OP_AUIPC:
                o_imm_extended = {i_inst[31:21], 12'b0};

            // J-type instructions imm[20|10:1|11|19:12], most significant 20 bits after a 21-bit
            // immediate jump offset
            `OP_JAL:
                o_imm_extended = {{11{i_inst[31]}}, i_inst[31], i_inst[19:12], i_inst[20],
                i_inst[30:21], 1'b0};

            // B-type instructions 
            `OP_BRANCH:
                o_imm_extended = 

            // R-type instructions, same as default, included for readability
            `OP_ALU:
                o_imm_extended = '0;

            default:
                o_imm_extended = '0;
        endcase
    end
endmodule
