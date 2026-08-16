module SPI_Slave #(
    parameter IDLE      = 3'b000,
    parameter CHK_CMD   = 3'b001,
    parameter WRITE     = 3'b010,
    parameter READ_ADD  = 3'b011,
    parameter READ_DATA = 3'b100
        
)(
    input MOSI_spi,SS_n_spi,clk_spi,rstn_spi,
    input tx_valid,
    input [7:0] tx_data,
    output reg [9:0] rx_data,
    output reg rx_valid,
    output reg MISO_spi
);
    reg [2:0] i;
    
    (* fsm_encoding = "gray" *)
    reg [2:0] cs,ns;
    reg rd_add;
    reg [3:0] bit_count,tx_count;
    reg [7:0] tx_data_reg;
    
    always @(posedge clk_spi) begin
        if (~rstn_spi) begin
            cs <= IDLE;
        end
        else begin
            cs <= ns;
        end
    end

    always @(*) begin
        ns=cs;
        case (cs)
            IDLE: 
                if (SS_n_spi == 1'b0) begin
                    ns = CHK_CMD;
                end 
                else begin
                    ns = IDLE;
                end
            CHK_CMD:
                if (SS_n_spi == 1'b0) begin
                    if (MOSI_spi == 1'b0) begin
                        ns = WRITE;
                    end 
                    else if (MOSI_spi == 1'b1 && rd_add == 1'b0) begin
                        ns = READ_ADD;
                    end
                    else if (MOSI_spi == 1'b1 && rd_add == 1'b1) begin
                        ns = READ_DATA;
                    end
                end
                else begin
                    ns = IDLE;
                end 
            WRITE: 
                if (SS_n_spi == 1'b0 && rx_valid == 1'b0) begin
                    ns = WRITE;
                end 
                else begin
                    ns = IDLE;
                end
            READ_ADD:
                if (SS_n_spi == 1'b0 && rx_valid == 1'b0) begin
                    ns = READ_ADD;
                end 
                else begin
                    ns = IDLE;
                end
            READ_DATA:
                if (SS_n_spi == 1'b0) begin
                    ns = READ_DATA;
                end 
                else begin
                    ns = IDLE;
                end
             default: ns = IDLE;    
        endcase
    end

    always @(posedge clk_spi) begin
        if (~rstn_spi) begin
            MISO_spi  <= 1'b0;
            rx_data <= 10'b0;
            rx_valid <= 1'b0;
            rd_add <= 1'b0;
            bit_count <= 4'b0;
            tx_count <= 0;  
        end    
        else if (SS_n_spi) begin
            MISO_spi  <= 1'b0;
            rx_data <= 10'b0;
            rx_valid <= 1'b0;
            //rd_add <= rd_add;
            bit_count <= 4'b0;
            tx_count <= 0;
        end
        else if (~SS_n_spi && cs == WRITE) begin
            rx_data <= {rx_data[8:0], MOSI_spi};
            if (bit_count == 9) begin
                rx_valid <= 1'b1;
                bit_count <= 4'b0;
                rx_data<=rx_data;
            end
            else begin
                bit_count <= bit_count + 1;
                rx_valid <= 1'b0;
            end   
        end
        else if (~SS_n_spi && cs == READ_ADD) begin
            rx_data <= {rx_data[8:0], MOSI_spi};
            if (bit_count == 9) begin
                rx_valid <= 1'b1;
                bit_count <= 4'b0;
                rd_add <= 1'b1;
            end
            else begin
                bit_count <= bit_count + 1;
            end 
        end
        else if (~SS_n_spi && cs == READ_DATA) begin
            rx_data <= {rx_data[8:0], MOSI_spi};
            if (bit_count == 9) begin
                rx_valid <= 1'b1;
                bit_count <= 4'b0;
                rd_add <= 1'b1;
            end
            else begin
                bit_count <= bit_count + 1;
                rx_valid <=0;
            end 
           if (tx_valid && tx_count <= 4'b0111) begin
                MISO_spi <= tx_data[7-tx_count];
                tx_count <= tx_count+1;
            end
            else if (tx_count == 8) begin
                tx_count<=0;
                rd_add <=0;
            end
            
        end
    end
endmodule