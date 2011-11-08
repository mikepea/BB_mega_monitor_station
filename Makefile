ARDUINO_DIR = /usr/share/arduino

AVR_TOOLS_PATH = /usr/bin
AVRDUDE_CONF   = /etc/avrdude.conf

TARGET       = BB_mega_monitor_station
BOARD_TAG    = mega
ARDUINO_PORT = /dev/ttyUSB0

ARDUINO_LIBS = OneWire DallasTemperature

include /opt/arduino-mk/Arduino.mk

install:
	install -o root -g root -m 0555 read_n_graphite /usr/local/bin/
