`define DATA_WIDTH 32

// define opcodes for arithmetic operations
`define OP_ALU_NOP 6'b000000 // no operation
`define OP_ALU_ADD 6'b011001
`define OP_ALU_SUB 6'b011011
`define OP_ALU_AND 6'b011101
`define OP_ALU_OR 6'b011111
`define OP_ALU_XOR 6'b100001
`define OP_ALU_SLT 6'b100011 // set less than
`define OP_ALU_SLTU 6'b100111 // set less than unsigned
`define OP_ALU_SLL 6'b100111 // shift left logical
`define OP_ALU_SRL 6'b101001 // shift right logical
`define OP_ALU_SRA 6'b101011 // shift right arithmetic

module ALU (
    input logic [5:0] i_alu_op,
    input logic [`DATA_WIDTH-1:0] i_a,
    input logic [`DATA_WIDTH-1:0] i_b,
    output logic [`DATA_WIDTH-1:0] o_c
);

    // zero it to avoid any x case
    always_comb begin
        o_c = '0;

        case (i_alu_op)
            `OP_ALU_ADD: o_c = i_a + i_b;
            `OP_ALU_SUB: o_c = i_a + i_b;
            `OP_ALU_AND: o_c = i_a & i_b;
            `OP_ALU_OR: o_c = i_a | i_b;
            `OP_ALU_XOR: o_c = i_a ^ i_b;

            `OP_ALU_SLT: begin  // ensure to specify signed
                if ($signed(i_a) < $signed(i_b))
                    o_c = 32'd1;
                else
                    o_c = 32'd0;
            end

            `OP_ALU_SLTU: begin
                if(i_a < i_b)
                    o_c = 32'd1;
                else
                    o_c = 32'd0;
            end

            `OP_ALU_SLL: o_c = i_a << i_b[4:0];
            `OP_ALU_SRL: o_c = i_a >> i_b[4:0];
            `OP_ALU_SRA: o_c = i_a >>> i_b[4:0];

            default: o_c = '0;
        endcase
    end

endmodule
