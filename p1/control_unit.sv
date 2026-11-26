// redefine the ALU operation codes

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

// branch unit code for "always jump"
`define BRANCH_JAL 3'b010 // jump and link

module control_unit(
    input logic i_clk,
    input logic i_rst, // reset

    // class flags from decoder
    input logic is_alu,
    input logic is_alui,
    input logic is_load,
    input logic is_store,
    input logic is_branch,
    input logic is_jal,
    input logic is_jalr,
    input logic is_lui,
    input logic is_auipc,
    input logic is_fence,

    // functs
    input logic [2:0] funct3,
    input logic [6:0] funct7,

    // indicate FETCH2
    output logic ir_write, // when 1, latch the memory output to IR

    output logic pc_write, // when 1, load the PC with next PC val

    // ALU operand A: 00 = rs1, 01 = PC, 10 = zero
    output logic [1:0] alu_src_a,

    // ALU operand B: 0 = rs2, 1 = immediate
    // rs2 only applies to R-type instructions, everything else uses imm
    output logic alu_src_b,

    // ALU opcodes
    output logic [5:0] alu_op,

    // indicate branch unit
    output logic branch, // branch, jump, jalr (b,j,i type)

    // indicate branch unit condition
    output logic [2:0] branch_opcode,

    // selects which value the register file writes into dest reg
    // 00 = ALU result, 01 = PC+4 and return address, 10 = data mem read
    output logic [1:0] result_mux,

    output logic reg_write, // when 1, write the result into dest reg

    // only for r-type and in memory cycle
    output logic mem_write // when 1, store to data mem
);

    // define the 6 FSM states
    typedef enum logic [2:0]{
        FETCH1 = 3'd0, // PC on instruction address bus
        FETCH2 = 3'd1, // latch instruction to IR
        DECODE = 3'd2, // register file read and immediate are ready
        EXECUTE = 3'd3, // ALU computes result, address, or target
        MEMORY = 3'd4, // load or store access to data memory
        WRITEBACK = 3'd5 // write dest reg and update PC
    } state_t;

    state_t state, next_state;

    // indicate whether or not the instruction is valid
    logic is_known;

    // indicate if instruction writes something into dest reg
    logic writes_reg;

    assign is_known = is_alu | is_alui | is_load | is_store | is_branch |
                      is_jal | is_jalr | is_lui | is_auipc | is_fence;

    // includes everything except store, branch, and fence
    assign writes_reg = is_alu | is_alui | is_load | is_jal | is_jalr | 
                        is_lui | is_auipc | is_fence;

    // state register advances on each clock edge
    always_ff @(posedge i_clk) begin

        // reset
        if (i_rst)
            state <= FETCH1;
        else
            state <= next_state;
    end

    // next state logic, instruction class picks the path
    always_comb begin
        next_state = FETCH1;

        case (state)
            FETCH1: next_state = FETCH2;
            FETCH2: next_state = DECODE;

            // proceed to execute UNLESS instruction is
            // not recognized or is fence, then go to writeback
            // without writing a register
            DECODE: begin
                if (is_known && !is_fence)
                    next_state = EXECUTE;
                else
                    next_state = WRITEBACK;
            end

            // deals with load and storing memory
            // branches have nothing to do with writeback or memory, so
            // FSM can start next_fetch immediately
            EXECUTE: begin
                if (is_load || is_store)
                    next_state = MEMORY;
                else if (is_branch)
                    next_state = FETCH1;
                else
                    next_state = WRITEBACK;
            end

            // loads need writeback to receive data
            MEMORY: begin
                if (is_load)
                    next_state = WRITEBACK;
                else
                    next_state = FETCH1;
            end

            // every path ends here, then fetches next instruction
            WRITEBACK: next_state = FETCH1;

            // restart for any other case
            default: next_state = FETCH1;
        endcase
    end

    // state-gated signals
    always_comb begin

        ir_write = 1'b0;
        pc_write = 1'b0;
        reg_write = 1'b0;
        mem_write = 1'b0;

        // latch the instruction only when it's valid (FETCH2)
        if (state == FETCH2)
            ir_write = 1'b1;

        // enable pc_write if at end of execute (branch) or end of
        // memory (store) or end of writeback (all other cases)
        if ((state == EXECUTE && is_branch) || (state == MEMORY && is_store) ||
             state == WRITEBACK)
             pc_write = 1'b1;

        // enable writing to dest reg only for writeback
        if (state == WRITEBACK && writes_reg)
            reg_write = 1'b1;

        // memory for store ONLY
        if (state == MEMORY && is_store)
            mem_write = 1'b1;
    end

    // class-based signals

    // ALU operand A
    always_comb begin
        // default, 00 = rs1 (R, I, load, store, jalr)
        alu_src_a = 2'b00;

        // 01 for PC (branch, jal, or auipc)
        if (is_branch || is_jal || is_auipc)
            alu_src_a = 2'b01;

        // 10 for zero
        else if (is_lui)
            alu_src_a = 2'b10;
    end

    // ALU operation select
    always_comb begin

        // default to no operation
        alu_op = `OP_ALU_NOP;

        if (is_alu || is_alui) begin
            case (funct3)
                // add/sub
                3'b000: alu_op = (is_alu && funct7[5]) ? `OP_ALU_SUB : `OP_ALU_ADD;

                // slli / slli
                3'b001: alu_op = `OP_ALU_SLL;

                // slt / slti
                3'b010: alu_op = `OP_ALU_SLT;

                // sltu / sltui
                3'b011: alu_op = `OP_ALU_SLTU;

                // xor / xori
                3'b100: alu_op = `OP_ALU_XOR;

                // srl/sra (plus i variants)
                3'b101: alu_op = funct7[5] ? `OP_ALU_SRA : `OP_ALU_SRL;

                // or/ori
                3'b110: alu_op = `OP_ALU_OR;

                // and/andi
                3'b111: alu_op = `OP_ALU_AND;

                default: alu_op = `OP_ALU_NOP;
            endcase
        end
        // don't forget address (load/store), target (branch/jal/jalr),
        // and lui/auipc use ADD
        else if (is_load || is_store || is_branch || is_jal || is_jalr ||
                 is_lui || is_auipc)
                alu_op = `OP_ALU_ADD;
    end

    // branch unit controls
    always_comb begin

        //enabled for branches, jal, and jalr
        branch = is_branch || is_jal || is_jalr;

        if (is_branch)
            branch_opcode = funct3;
        else
            branch_opcode = `BRANCH_JAL;
    end

    // register write data select
    always_comb begin
        // default: R, I ALU, lui and auipc
        result_mux = 2'b00;

        // jal and jalr: write the return address of PC+4
        if (is_jal || is_jalr)
            result_mux = 2'b01;

        // load: data memory read
        else if (is_load)
            result_mux = 2'b10;
    end

endmodule