`timescale 1ns/1ps

module tb_uart_led;

localparam integer DIV = 8;

reg clk_50mhz = 1'b0;
reg rst_p = 1'b1;
reg uart_rxd = 1'b1;

wire uart_txd;
wire [7:0] led;

integer checks = 0;

always #10 clk_50mhz = ~clk_50mhz;

lab6_uart_led #(
    .CLK_HZ(800),
    .BAUD(100)
) dut (
    .clk_50mhz(clk_50mhz),
    .rst_p(rst_p),
    .uart_rxd(uart_rxd),
    .uart_txd(uart_txd),
    .led(led)
);

task automatic send_byte(input [7:0] value);
    integer bit_index;
    begin
        uart_rxd = 1'b0;
        repeat (DIV) @(posedge clk_50mhz);

        for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
            uart_rxd = value[bit_index];
            repeat (DIV) @(posedge clk_50mhz);
        end

        uart_rxd = 1'b1;
        repeat (DIV) @(posedge clk_50mhz);
    end
endtask

task automatic receive_echo(input [7:0] expected);
    integer bit_index;
    reg [7:0] observed;
    begin
        observed = 8'h00;

        @(negedge uart_txd);
        repeat (DIV + DIV / 2) @(posedge clk_50mhz);

        for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
            observed[bit_index] = uart_txd;
            repeat (DIV) @(posedge clk_50mhz);
        end

        if (observed !== expected)
            $fatal(1, "echo=%h expected=%h", observed, expected);

        repeat (DIV) @(posedge clk_50mhz);
    end
endtask

task automatic send_command(
    input [7:0] command,
    input       expected_led
);
    begin
        fork
            send_byte(command);
            receive_echo(command);
        join

        @(posedge clk_50mhz);
        #1;

        if (led[0] !== expected_led)
            $fatal(
                1,
                "command=%h led=%b expected=%b",
                command,
                led[0],
                expected_led
            );

        if (led[7:1] !== 7'b0000000)
            $fatal(1, "unused LEDs must remain off");

        checks = checks + 1;
    end
endtask

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_uart_led);

    repeat (4) @(posedge clk_50mhz);
    rst_p = 1'b0;

    send_command(8'h30, 1'b0); // '0': OFF
    send_command(8'h31, 1'b1); // '1': ON
    send_command(8'h31, 1'b1); // '1' 반복: ON 유지
    send_command(8'h32, 1'b0); // '2': OFF로 반전
    send_command(8'h32, 1'b1); // '2': ON으로 반전
    send_command(8'h41, 1'b1); // 'A': 상태 유지
    send_command(8'h30, 1'b0); // '0': OFF

    if (dut.rx_framing_error)
        $fatal(1, "unexpected framing error");

    $display(
        "LAB6_ASSIGNMENT7_UART_LED_PASS checks=%0d",
        checks
    );

    $finish;
end

initial begin
    #100000;
    $fatal(1, "timeout");
end

endmodule