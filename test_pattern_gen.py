#!/usr/bin/python

from pattern_generator import pattern_generator
import time

pat_gen = pattern_generator(debug=True)

print "Drive single gpio pattern, no repeat"
pat_gen.disable_pattern()
pat_gen.spi_slave.write_bytes(start_address=0x000000,write_byte_list=[0xF5, 0x53, 0x72],dest="sram")
pat_gen.set_end_address(end_address=0x000002)
pat_gen.select_timestep(timestep=0)
pat_gen.select_num_gpio(num_gpio=1)
pat_gen.enable_pattern()
pat_gen.wait_for_pattern_done()
pat_gen.spi_slave.read_bytes(start_address=0x000000,num_bytes=5,dest="regmap")
pat_gen.spi_slave.read_bytes(start_address=0x000000,num_bytes=3,dest="sram")

#print "Drive single gpio pattern, with repeat for 1 second"
#pat_gen.disable_pattern()
#pat_gen.spi_slave.write_bytes(start_address=0x000000,write_byte_list=[0xF5, 0x53, 0x72],dest="sram")
#pat_gen.set_end_address(end_address=0x000002)
#pat_gen.select_timestep(timestep=0)
#pat_gen.select_num_gpio(num_gpio=1)
#pat_gen.enable_repeat()
#time.sleep(1)
#pat_gen.disable_repeat()
#pat_gen.spi_slave.read_bytes(start_address=0x000000,num_bytes=5,dest="regmap")
#pat_gen.spi_slave.read_bytes(start_address=0x000000,num_bytes=3,dest="sram")

#print "Drive dual gpio pattern, no repeat"
#pat_gen.spi_slave.write_bytes(start_address=0x000000,write_byte_list=[0x9C, 0x43, 0x9C],dest="sram")
#pat_gen.set_end_address(end_address=0x000002)
#pat_gen.select_timestep(timestep=0)
#pat_gen.select_num_gpio(num_gpio=2)
#pat_gen.enable_pattern()
#pat_gen.wait_for_pattern_done()
#pat_gen.spi_slave.read_bytes(start_address=0x000000,num_bytes=5,dest="regmap")
#pat_gen.spi_slave.read_bytes(start_address=0x000000,num_bytes=3,dest="sram")

#print "Drive quad gpio pattern, no repeat"
#pat_gen.spi_slave.write_bytes(start_address=0x000000,write_byte_list=[0x96, 0xE1, 0xA5],dest="sram")
#pat_gen.set_end_address(end_address=0x000002)
#pat_gen.select_timestep(timestep=0)
#pat_gen.select_num_gpio(num_gpio=4)
#pat_gen.enable_pattern()
#pat_gen.wait_for_pattern_done()
#pat_gen.spi_slave.read_bytes(start_address=0x000000,num_bytes=5,dest="regmap")
#pat_gen.spi_slave.read_bytes(start_address=0x000000,num_bytes=3,dest="sram")

print "Timestep is %d" % pat_gen.select_timestep_from_real_number(real_time=14e-6)
