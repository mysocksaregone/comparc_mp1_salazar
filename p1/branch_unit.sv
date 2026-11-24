`define DATA_WIDTH 32

// define opcodes for branch types
`define BRANCH_BEQ 3'b000 // branch if equal
`define BRANCH_BLT 3'b100 // branch if less than
`define BRANCH_BLTU 3'b110 // branch if less than unsigned
`define BRANCH_BNE 3'b001 // branch if not equal
`define BRANCH_BGE 3'b101 // branch if greater than (or eq)
`define BRANCH_BGEU 3'b111 // ^^ unsigned
`define BRANCH_JAL 3'b010 // jump and link

module branch_unit(
    input logic i_branch,  // should a branch operation be performed?
    input logic [2:0] i_branch_op, // THESE ARE THE FUNCT 3 VALUES
    input logic [`DATA_WIDTH-1:0] i_a,
    input logic [`DATA_WIDTH-1:0] i_b,

    output logic o_branch // should we take the branch?
);

    always_comb begin
        o_branch = 1'b0;

        case (i_branch_op)

            `BRANCH_BEQ: o_branch = (i_rs1 == i_b);
            `BRANCH_BLT: o_branch = ($signed(i_a) < $signed(i_b));
            `BRANCH_BLTU: o_branch = (i_a < i_b);
            `BRANCH_BNE: o_branch = (i_a != i_b);
            `BRANCH_BGE: o_branch = ($signed(i_a) >= $signed(i_b));
            `BRANCH_BGEU: o_branch = (i_a >= i_b);

            // jal and jalr always jump
            `BRANCH_JAL: o_branch = 1'b1;

            default: o_branch = 1'b0;
        endcase

    end

endmodule
