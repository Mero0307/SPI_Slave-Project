# =========================================================
# SPI Wrapper - Basys3
# =========================================================

# Clock signal - Basys3 100 MHz
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]


# =========================================================
# Switches / SPI Inputs
# =========================================================

set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports rstn]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports MOSI]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports SS_n]


# =========================================================
# SPI Output
# =========================================================

set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33} [get_ports MISO]


# =========================================================
# Buttons
# =========================================================

set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports rst]


# =========================================================
# Configuration
# =========================================================

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]


# =========================================================
# ILA Debug Core
# =========================================================

create_debug_core u_ila_0 ila

set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]

# Input pipeline stage
set_property C_INPUT_PIPE_STAGES 1 [get_debug_cores u_ila_0]

set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]


# =========================================================
# ILA CLOCK
# =========================================================

set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_IBUF_BUFG]]


# =========================================================
# ILA PROBE 0 - MISO
# =========================================================

set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 1 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list MISO_OBUF]]


# =========================================================
# ILA PROBE 1 - MOSI
# =========================================================

create_debug_port u_ila_0 probe

set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 1 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list MOSI_IBUF]]


# =========================================================
# ILA PROBE 2 - rstn
# =========================================================

create_debug_port u_ila_0 probe

set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list rstn_IBUF]]


# =========================================================
# ILA PROBE 3 - SS_n
# =========================================================

create_debug_port u_ila_0 probe

set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list SS_n_IBUF]]


# =========================================================
# DEBUG HUB
# =========================================================

# Actual system clock = 100 MHz
set_property C_CLK_INPUT_FREQ_HZ 100000000 [get_debug_cores dbg_hub]

set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]

connect_debug_port dbg_hub/clk [get_nets clk_IBUF_BUFG]

