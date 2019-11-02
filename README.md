# cmod_a7_pattern_generator_v1

This Systemverilog design is intended for a Digilent Cmod A7 FPGA board.
spi_regmap_top.sv is the top-level file with all the instances.

This design builds upon my "cmod_a7_spi_sram" repository. New features include:
(1) Pattern Generator       - allows 1, 2, 4 or 8 GPIO pins to drive levels from stored binary data in SRAM
(2) Revision Indictor       - push button_1 and the version is shown by the number of LED flashes
(3) Micro SD PMOD interface - the SPI slave now has a bypass mode to allow the PMOD connector to be addressed

The Pattern Generator uses regmap registers to hold configuration details. Here is what can be configured:
(1) # of GPIO outputs - 1, 2, 4 or 8
(2) Timestep          - 24 selections available 2 ^ n divisions of the 12MHz oscillator clock
(3) Ending Address    - Pattern always starts at SRAM address 0x000000
(4) Repeat Enable     - Allows the SRAM address index to wrap back to 0x000000 and the pattern drives again
(5) Pattern Trigger   - Starts the pattern
Presently I do not have a capture ability to capture levels from other GPIOs and load that into the SRAM.

The Revision Indicator will pulse one of the board LEDs on for 0.7s and off for 0.7s. This allows the user to see which version of the design is loaded in the boards flash memory.

Eventually I want to switch from SRAM to Micro SD for my pattern memory. I have a mirco SD PMOD module which connects to the PMOD interface on the board. I have a python class which can read and write to the SD card from the Raspberry Pi. For the present, the Micro SD PMOD interface just allows the single SPI interface to also connect to the PMOD connector pins.

I hope to create a SPI master for the FPGA which will read pattern data from the Micro SD memory and provide that to the pattern generator.  
