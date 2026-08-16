# SPI_Slave-Project
SPI Slave with Internal Memory (SPRAM)

A Verilog implementation of an SPI slave interface backed by a single-port RAM, targeting the Digilent Basys3 (Xilinx Artix-7, xc7a35ticpg236). The slave decodes a simple 4-command protocol over MOSI and lets an SPI master write to and read back from an on-chip 256×8 memory array.

Features
Single-bit SPI slave (MOSI in / MISO out), no MOSI/MISO combined line
4-command protocol: write address, write data, read address, read data
256-byte internal memory (SPRAM), 8-bit data width
Fully synchronous design, single clock domain
Verified in simulation with a self-checking testbench
Includes an Integrated Logic Analyzer (ILA) hookup for on-hardware debug via Vivado
Architecture
                 ┌─────────────────────── SPI_Wrapper ───────────────────────┐
                 │                                                            │
  MOSI ─────────►│                                                            │
  SS_n ─────────►│                 rx_data ──────────►                       │
  clk  ─────────►│    SPI_Slave    rx_valid ─────────►      SPRAM            │
  rstn ─────────►│                                                256x8 mem  │
                 │                 ◄────────── tx_data                       │
  MISO ◄─────────│                 ◄───────── tx_valid                       │
                 │                                                            │
                 └────────────────────────────────────────────────────────────┘

SPI_Slave handles the serial protocol and drives a 10-bit rx_data bus (2 command bits + 8 address/data bits) into SPRAM, pulsing rx_valid for one clock when a full command word has been received. SPRAM responds to read commands by pulsing tx_valid with the requested byte on tx_data, which SPI_Slave then shifts out on MISO.

Protocol

Each transaction is a 10-bit serial word: {cmd[1:0], payload[7:0]}.

cmd (rx_data[9:8])	Meaning	Payload
2'b00	Write address	8-bit address → latched as wr_addr
2'b01	Write data	8-bit data → mem[wr_addr]
2'b10	Read address	8-bit address → latched as rd_addr
2'b11	Read data	(ignored) → triggers mem[rd_addr] to be returned on MISO

A typical read sequence is: read address (set the address to read from) followed by read data (fetch and shift the byte back out).

FSM

SPI_Slave is driven by a 5-state FSM:

IDLE — waits for SS_n to go low
CHK_CMD — samples the first MOSI bit; 0 → WRITE, 1 → READ_ADD or READ_DATA depending on the internal rd_add flag
WRITE — shifts in the remaining 9 bits (2nd cmd bit + 8-bit payload), pulses rx_valid
READ_ADD — shifts in the read address, pulses rx_valid, sets rd_add
READ_DATA — shifts in a full command word, checks rx_data[9:8] == 2'b11, pulses rx_valid to trigger the RAM read, then shifts tx_data_reg out on MISO one bit per clock

All states return to IDLE once SS_n goes high.

Repository structure
SPI_Slave.v        SPI protocol handler / FSM
SPI_Wrapper.v       Top-level wrapper instantiating SPI_Slave + SPRAM
SPRAM.v              256x8 single-port RAM with command decode
tb_spi_slave.v       Self-checking testbench
SPI_Wrapper.xdc      Basys3 pin/timing constraints + ILA debug core
Simulation

Simulated with Icarus Verilog:

bash
iverilog -o sim SPI_Slave.v SPI_Wrapper.v SPRAM.v tb_spi_slave.v
vvp sim

The testbench exercises all four commands (write address, write data, read address, read data) and checks the shifted-out MISO data against the expected memory contents.

Hardware (Basys3)

SPI_Wrapper.xdc maps the design to the Basys3 board (100 MHz system clock, switches for rstn/SS_n/MOSI, an LED for MISO) and sets up an ILA core for on-board probing of MOSI, MISO, SS_n, rstn, and clk.

Note: The ILA debug core introduces an internal hold-timing path (probeDelay1_reg) unrelated to the SPI/RAM logic. A set_false_path -hold exception for it is included at the end of the XDC — it must stay after the create_debug_core/connect_debug_port calls, since the probe-delay cells don't exist until the debug core is built.
