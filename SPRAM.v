module SPRAM #(
    parameter MEM_DEPTH = 256,
    parameter ADDR_SIZE = 8,
    parameter MEM_WIDTH = 8
)(
    input [9:0] din,
    input rx_valid,clk_ram,rstn_ram,//flag,
    output reg [7:0] dout,
    output reg tx_valid
);
    reg [MEM_WIDTH-1:0] mem [MEM_DEPTH-1:0];
    reg [ADDR_SIZE-1:0] wr_addr,rd_addr;

    always @(posedge clk_ram) begin
        if (~rstn_ram) begin
            dout <= 8'b0;
            tx_valid <= 1'b0;
            wr_addr <= 8'b0;
            rd_addr <= 8'b0;
        end
        else begin
            if (rx_valid) begin
                tx_valid <=0;
                case (din[9:8])
                2'b00: begin
                    wr_addr <= din[7:0]; 
                end
                2'b01: begin
                    mem[wr_addr] <= din[7:0];
                end
                2'b10: begin
                    rd_addr <= din[7:0];
                end
                2'b11: begin
                    tx_valid<=~tx_valid;
                    dout <= mem[rd_addr];
                end
                endcase
            end
        end
    end
endmodule