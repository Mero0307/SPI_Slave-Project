vlib work
 vlog SPI_Slave.v SPRAM.v SPI_Wrapper.v tb_spi_slave.v
 vsim -voptargs=+acc work.tb_spi_slave
 add wave *
 run -all
 #quit -sim