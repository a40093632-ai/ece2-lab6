`timescale 1ns/1ps

module lab6_uart_led #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer BAUD = 9_600
) (
    input  wire       clk_50mhz,
    input  wire       rst_p,
    input  wire       uart_rxd,
    output wire       uart_txd,
    output wire [7:0] led
);

localparam integer DIV =
    (CLK_HZ + BAUD / 2) / BAUD;

wire [7:0] rx_data;
wire       rx_valid;
wire       rx_framing_error;
wire       tx_ready;

reg        tx_valid;
reg [7:0]  tx_data;
reg        led_state;

uart_rx #(
    .DIV(DIV)
) u_rx (
    .clk(clk_50mhz),
    .rst_p(rst_p),
    .rx(uart_rxd),
    .data(rx_data),
    .valid(rx_valid),
    .framing_error(rx_framing_error)
);

uart_tx #(
    .DIV(DIV)
) u_tx (
    .clk(clk_50mhz),
    .rst_p(rst_p),
    .valid(tx_valid),
    .data(tx_data),
    .ready(tx_ready),
    .tx(uart_txd)
);

always @(posedge clk_50mhz) begin
    if (rst_p) begin
        tx_valid  <= 1'b0;
        tx_data   <= 8'h00;
        led_state <= 1'b0;
    end
    else begin
        tx_valid <= 1'b0;

        if (rx_valid) begin
            case (rx_data)
                8'h30: led_state <= 1'b0;       // 문자 '0': LED 끄기
                8'h31: led_state <= 1'b1;       // 문자 '1': LED 켜기
                8'h32: led_state <= ~led_state; // 문자 '2': LED 반전
                default: led_state <= led_state;
            endcase

            if (tx_ready) begin
                tx_data  <= rx_data;
                tx_valid <= 1'b1;
            end
        end
    end
end

assign led = {7'b0000000, led_state};

endmodule