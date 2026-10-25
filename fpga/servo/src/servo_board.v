`timescale 1ns/1ps

module servo_board #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer DEBOUNCE_CYCLES = 1_000_000
) (
    input  wire clk_50mhz,
    input  wire rst_p,
    input  wire left_button,
    input  wire right_button,
    output wire servo
);

wire left_pulse;
wire right_pulse;

button_onepulse #(
    .STABLE_CYCLES(DEBOUNCE_CYCLES)
) u_left_button (
    .clk(clk_50mhz),
    .rst_p(rst_p),
    .button(left_button),
    .pulse(left_pulse)
);

button_onepulse #(
    .STABLE_CYCLES(DEBOUNCE_CYCLES)
) u_right_button (
    .clk(clk_50mhz),
    .rst_p(rst_p),
    .button(right_button),
    .pulse(right_pulse)
);

servo_ctrl #(
    .CLK_HZ(CLK_HZ)
) u_servo (
    .clk_50mhz(clk_50mhz),
    .rst_p(rst_p),
    .left_pulse(left_pulse),
    .right_pulse(right_pulse),
    .servo(servo)
);

endmodule