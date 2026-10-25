
module fades #(
    parameter INC_DEC_INTERVAL = 2000,     // CLK frequency is 12MHz, so 12,000 cycles is 1ms
    parameter INC_DEC_MAX = 1000,            // amount of steps it takes to go to next state // Transition to next state after 200 increments / decrements, which is 0.2s
    parameter PWM_INTERVAL = 1000,          // length of an interval // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX,
    parameter START_STATE = 0
)(
    input logic clk,
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value
);

    // Previous inc and dec values only give us triangles.
    // we need trapezoids. up for 60, on for 120, down for 60,
    // off for 120 and repeat cycle.
    localparam PWM_UP = 3'd0;
    localparam PWM_HIGH1 = 3'd1;
    localparam PWM_HIGH2 = 3'd2;
    localparam PWM_DOWN = 3'd3;
    localparam PWM_LOW1 = 3'd4;
    localparam PWM_LOW2 = 3'd5;

    // Declare state variables
    logic [2:0] current_state = START_STATE;
    logic [2:0] next_state;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    // sets the correct brightness for the differing starting states of the colors
    initial begin
        if (START_STATE == PWM_HIGH1 || START_STATE == PWM_HIGH2 || START_STATE == PWM_DOWN)
            pwm_value = PWM_INTERVAL;
        else
            pwm_value = 0;
    end

    // Register the next state of the FSM
    always_ff @(posedge time_to_transition)
        current_state <= next_state;

    // Compute the next state of the FSM
    always_comb begin
        case (current_state)
            PWM_LOW2:
                next_state = PWM_UP;
            default:
                next_state = current_state + 1;
        endcase
    end

    // for every clock tick
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL -1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // only increase if the state is at up or down (increase or decreasing)
    always_ff @(posedge time_to_inc_dec) begin
        case (current_state)
            PWM_UP:
                pwm_value <= pwm_value + INC_DEC_VAL;
            PWM_DOWN:
                pwm_value <= pwm_value - INC_DEC_VAL;
            default:
                pwm_value <= pwm_value;
        endcase

        if (inc_dec_count == INC_DEC_MAX - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

endmodule
