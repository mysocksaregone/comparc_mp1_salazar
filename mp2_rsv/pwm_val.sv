`include "fades.sv"
`include "pwm.sv"


module pwm_val #(
    parameter PWM_INTERVAL = 1000,  // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_INTERVAL = 2000,
    parameter START_STATE = 0
)(
    input logic     clk,
    output logic    pwm_out
);

    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value;

    fades #(
        .PWM_INTERVAL       (PWM_INTERVAL),
        .INC_DEC_INTERVAL   (INC_DEC_INTERVAL),
        .INC_DEC_MAX        (PWM_INTERVAL),
        .START_STATE        (START_STATE)
    ) u1 (
        .clk            (clk),
        .pwm_value      (pwm_value)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2 (
        .clk            (clk),
        .pwm_value      (pwm_value),
        .pwm_out        (pwm_out)
    );

endmodule
