module SPI_Wrapper (
    input MOSI,
    input SS_n,
    input clk,rstn,
    output MISO
);

    wire [9:0] rx_data_spi;
    wire [7:0] tx_data_spi;
    wire rx_valid_spi,tx_valid_spi;
    
    SPI_Slave slave (
        .MOSI_spi(MOSI),
        .SS_n_spi(SS_n),
        .clk_spi(clk),
        .rstn_spi(rstn),
        .tx_valid(tx_valid_spi),
        .tx_data(tx_data_spi),
        .rx_data(rx_data_spi),
        .rx_valid(rx_valid_spi),
        .MISO_spi(MISO)
    );   

    SPRAM RAM (
        .din(rx_data_spi),
        .rx_valid(rx_valid_spi),
        .clk_ram(clk),
        .rstn_ram(rstn),
        .dout(tx_data_spi),
        .tx_valid(tx_valid_spi)
    );      

endmodule 