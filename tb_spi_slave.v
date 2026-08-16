module tb_spi_slave  ();
    reg MOSI;
    reg SS_n;
    reg clk;
    reg rstn;
    wire MISO;

    SPI_Wrapper DUT (
        .MOSI(MOSI),
        .SS_n(SS_n),
        .clk(clk),
        .rstn(rstn),
        .MISO(MISO)
    );

    wire rx_valid = DUT.rx_valid_spi;
    wire [9:0] rx_data = DUT.rx_data_spi;
    wire tx_valid = DUT.tx_valid_spi;
    wire [7:0] tx_data = DUT.tx_data_spi;
    wire [3:0] bit_count= DUT.slave.bit_count;
    wire [2:0] cs = DUT.slave.cs;
    wire [7:0] wr_addr = DUT.RAM.wr_addr;
    wire [7:0] rd_addr = DUT.RAM.rd_addr;
    wire rd_add = DUT.slave.rd_add;
    wire [3:0] tx_count = DUT.slave.tx_count;


    initial begin
        clk=0;
        forever begin
            #5 clk=~clk;
        end
    end

    initial begin

        $readmemh("ram_values.dat",DUT.RAM.mem);
        rstn = 0;
        SS_n = 1;
        repeat (5) begin 
            MOSI = $random;
            @(negedge clk);
        end
        repeat (2) begin
            rstn = 1;
            SS_n = 1;
            repeat (5) @(negedge clk);
        /////////////////////////////////////////////
                //write address
        /////////////////////////////////////////////
        
        // start communication
            rstn = 1;
            SS_n = 0;
            MOSI=0;
            @(negedge clk);
        // write address command
            repeat (2) begin
                MOSI = 0;
                @(negedge clk);
            end
        //wrire address 
            repeat (9) begin
                MOSI = $random;
                @(negedge clk);
            end
            // @(negedge clk);
        // end communication
            SS_n =1;
            @(negedge clk);
        
        /////////////////////////////////////////////
                //write data
        /////////////////////////////////////////////
        
        // start communication
            SS_n =0;
            MOSI=0;
            @(negedge clk);
        
        // write data command
            MOSI =0;
            @(negedge clk);

            MOSI=1;
            @(negedge clk);
        
        // write data
            repeat (9) begin
                MOSI = $random;
                @(negedge clk);
            end

        // end communication
            SS_n =1;
            @(negedge clk);
  
        /////////////////////////////////////////////
            // Read Address
        /////////////////////////////////////////////
        
        // start communication
            SS_n = 0;
            MOSI=1;
            @(negedge clk);
        // read address command
            MOSI = 1;
            @(negedge clk);

            MOSI = 1;
            @(negedge clk);

            MOSI = 0;
            @(negedge clk);
        //read address 
            repeat (8) begin
                MOSI = ~MOSI;
                @(negedge clk);
            end

        // end communication
            SS_n =1;
            @(negedge clk);

        /////////////////////////////////////////////
            // Read data
        /////////////////////////////////////////////
        
        // start communication
            SS_n = 0;
            MOSI=0;
            @(negedge clk);
        // read address command
            MOSI =1;
            @(negedge clk);

            MOSI=1;
            @(negedge clk);

            MOSI=1;
            @(negedge clk);
        //read address 
            repeat (8) begin
                MOSI = $random;
                @(negedge clk);
            end

        // wait for tx flag
            repeat (9) @(negedge clk); @(negedge clk);

        // end communication
            SS_n =1;
            repeat (2) @(negedge clk);
        end
        $stop;
    end    
endmodule