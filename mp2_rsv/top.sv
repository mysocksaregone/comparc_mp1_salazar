`include "pwm_val.sv"

// Fade top level module

module top #(
    parameter PWM_INTERVAL = 1000,
    parameter INC_DEC_INTERVAL = 2000
)(
    input logic     clk,
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    logic pwm_out_r;
    logic pwm_out_g;
    logic pwm_out_b;

    // red starting off at pwm_high2
    pwm_val #(
        .PWM_INTERVAL       (PWM_INTERVAL),
        .INC_DEC_INTERVAL   (INC_DEC_INTERVAL),
        .START_STATE        (1)
    ) red (
        .clk                (clk),
        .pwm_out            (pwm_out_r)
    );

    // green starting off at pwm_up
    pwm_val #(
        .PWM_INTERVAL       (PWM_INTERVAL),
        .INC_DEC_INTERVAL   (INC_DEC_INTERVAL),
        .START_STATE        (5)
    ) green (
        .clk                (clk),
        .pwm_out            (pwm_out_g)
    );

    // blue starting off at pwm_low1
    pwm_val #(
        .PWM_INTERVAL       (PWM_INTERVAL),
        .INC_DEC_INTERVAL   (INC_DEC_INTERVAL),
        .START_STATE        (3)
    ) blue (
        .clk                (clk),
        .pwm_out            (pwm_out_b)
    );

    assign RGB_R = ~pwm_out_r;
    assign RGB_G = ~pwm_out_g;
    assign RGB_B = ~pwm_out_b;


endmodule