#!/usr/bin/python

from spi_slave import spi_slave
import RPi.GPIO as GPIO
import time

class pattern_generator :
	
	_LBUS_COMMAND_ADDR         = 0x000000
	_ENABLE_PAT_GEN            = 0x01
	_REPEAT_ENABLE_PAT_GEN     = 0x02
	_LBUS_CONFIG_ADDR          = 0x000001
	_SEL_GPIO_BIT_MASK         = 0x03
	_SEL_1_GPIO                = 0x00
	_SEL_2_GPIO                = 0x01
	_SEL_4_GPIO                = 0x02
	_SEL_8_GPIO                = 0x03
	_SEL_TIMESTEP_BIT_MASK     = 0xF8
	_SEL_TIMESTEP_NUM_SHIFTS   = 3
	_END_ADDRESS_PAT_GEN_ADDR  = 0x000002
	_END_ADDRESS_PAT_GEN_BYTES = 3
	_MIN_TIMESTEP_TIME         = (1.0/12.0) * 1e-6 * 2
	_MAX_TIMESTEP_TIME         = _MIN_TIMESTEP_TIME * (2**23)
	_PATTERN_DONE_GPIO         = 4
	 
	 # Constructor
	def __init__(self, debug=False): # 2MHz
		self.spi_slave = spi_slave(debug = debug)
		self.debug     = debug
		GPIO.setwarnings(False)
		GPIO.setmode(GPIO.BCM) #Using home connector board
		GPIO.setup(self._PATTERN_DONE_GPIO, GPIO.IN, pull_up_down=GPIO.PUD_DOWN) # pull-down on pin
		
	def enable_pattern(self):
		if (self.debug == True):
			print "Called: enable_pattern"
		self.spi_slave.read_modify_write(address=self._LBUS_COMMAND_ADDR,dest="regmap",value=self._ENABLE_PAT_GEN)
		
	def disable_pattern(self):
		if (self.debug == True):
			print "Called: disable_pattern"
		self.spi_slave.read_clear_write(address=self._LBUS_COMMAND_ADDR,dest="regmap",value=self._ENABLE_PAT_GEN)

	def enable_repeat(self):
		if (self.debug == True):
			print "Called: enable_repeat"
		self.spi_slave.read_modify_write(address=self._LBUS_COMMAND_ADDR,dest="regmap",value=self._REPEAT_ENABLE_PAT_GEN)
		
	def disable_repeat(self):
		if (self.debug == True):
			print "Called: disable_repeat"
		self.spi_slave.read_clear_write(address=self._LBUS_COMMAND_ADDR,dest="regmap",value=self._REPEAT_ENABLE_PAT_GEN)
	
	def select_num_gpio(self,num_gpio=1):
		if (self.debug == True):
			print "Called: select_num_gpio"
		if (num_gpio > 8 or num_gpio in [0,3,5,6,7]):
			print "Error num_gpio must be 1, 2, 4 or 8"
			return 0
		elif (num_gpio == 1):
			encoded_val = self._SEL_1_GPIO
		elif (num_gpio == 2):
			encoded_val = self._SEL_2_GPIO
		elif (num_gpio == 4):
			encoded_val = self._SEL_4_GPIO
		elif (num_gpio == 8):
			encoded_val = self._SEL_8_GPIO
		self.spi_slave.write_bit_field(address=self._LBUS_CONFIG_ADDR,dest="regmap",bit_mask=self._SEL_GPIO_BIT_MASK,value=encoded_val)
	
	def select_timestep(self,timestep=23):
		if (self.debug == True):
			print "Called: select_timestep"
		if (timestep > 23):
			print "Error: timestep must be 23 or less"
			return 0
		else:
			byte_val = (0xFF & timestep) << self._SEL_TIMESTEP_NUM_SHIFTS
			self.spi_slave.write_bit_field(address=self._LBUS_CONFIG_ADDR,dest="regmap",bit_mask=self._SEL_TIMESTEP_BIT_MASK,value=byte_val)
	
	def set_end_address(self,end_address=0x000000):
		if (self.debug == True):
			print "Called: set_end_address"
		if (end_address > self.spi_slave._MAX_ADDRESS):
			print "Error: address must be less than or equal to 0x%06x" % self.spi_slave._MAX_ADDRESS
		else:
			byte1 = (end_address & 0xFF0000) >> 16
			byte2 = (end_address & 0x00FF00) >> 8
			byte3 = (end_address & 0x0000FF)
			self.spi_slave.write_bytes(start_address=self._END_ADDRESS_PAT_GEN_ADDR,dest="regmap",write_byte_list=[byte1,byte2,byte3])
	
	def select_timestep_from_real_number(self,real_time=1e-3):
		if (real_time > self._MAX_TIMESTEP_TIME):
			print "Real time value %.2e is greater than the maximum timestep of %.2e" % (real_time,self._MAX_TIMESTEP_TIME)
			return 23
		else:
			for step in range(0,24):
				if (abs(self._MIN_TIMESTEP_TIME * (2**step)-real_time) <= abs(self._MIN_TIMESTEP_TIME * (2**(step+1))-real_time)):
					if (self.debug == True):
						print "Timestep %d has a value of %.2e seconds and is the closest timestep to real_time value of %.2e" % (step,self._MIN_TIMESTEP_TIME * (2**step),real_time)
					return step
	
	def wait_for_pattern_done(self):
		if (self.debug == True):
			print "Called: wait_for_pattern_done"
		while not ( GPIO.input(self._PATTERN_DONE_GPIO) ):
			pass
		if (self.debug == True):
			print "Pattern complete"
		self.disable_pattern()
		
