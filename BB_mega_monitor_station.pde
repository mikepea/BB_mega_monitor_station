
#include <OneWire.h>
#include <DallasTemperature.h>

#define DOOR_BELL_PIN 2
#define ONE_WIRE_BUS 3
#define HACKSPACE_OPEN_SWITCH 4
#define HACKSPACE_OPEN_DISPLAY 5

const int pinDoorLock = 24;
const int pinDoorOwl = 23;

#define LDR_ANALOG_PIN 0

#define MAX_DEVS 10

// discovered, and now hardcoded
#define OUR_THERMOMETER 0x10, 0x69, 0xA7, 0xB7, 0x0, 0x08, 0x0, 0xAD
#// 28 9A 3B 10 03 00 00 48

// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);

// Pass our oneWire reference to Dallas Temperature.
DallasTemperature sensors(&oneWire);

// arrays to hold device address
DeviceAddress therms[MAX_DEVS];

int num_devices = 0;

//-----------------------------------------------------------------------------

#include <LiquidCrystal.h>

// LiquidCrystal display with:
// rs on pin 6
// rw on pin 7
// enable on pin 8
// d4, d5, d6, d7 on pins 9, 10, 11, 12
LiquidCrystal lcd(6, 7, 8, 9, 10, 11, 12);
int ledPin = 13;		    // LED connected to digital pin 13
int recvPin=0;
int wait=1000;
int val=0;

//-----------------------------------------------------------------------------

// function to print a device address
void printAddress(DeviceAddress deviceAddress)
{
  for (uint8_t i = 0; i < 8; i++)
  {
    if (deviceAddress[i] < 16) Serial.print("0");
    Serial.print(deviceAddress[i], HEX);
  }
}

void discover_onewire_devs(int n) {

    // Method 1:
    // search for devices on the bus and assign based on an index.  ideally,
    // you would do this to initially discover addresses on the bus and then
    // use those addresses and manually assign them (see above) once you know
    // the devices on your bus (and assuming they don't change).

    for (int i=0; i<n; i++) {
        if (!sensors.getAddress(therms[i], i)) {
            Serial.print("Unable to find address for Device ");
            Serial.print(i, DEC);
            Serial.println();
        } else {
            Serial.print("Device Address: ");
            printAddress(therms[i]);
            Serial.println();
        }
    }

}

// function to print the temperature for a device
void printTemperature(DeviceAddress deviceAddress)
{
  // method 2 - faster
  float tempC = sensors.getTempC(deviceAddress);
  Serial.print("Temp C: ");
  Serial.print(tempC);
  Serial.println();
}

boolean is_hackspace_open() {
  int val = digitalRead(HACKSPACE_OPEN_SWITCH);
  if ( val == HIGH ) {
  	return true;
  } else {
  	return false;
  }
  
}

void display_hackspace_open_state(boolean state) {
  if ( state == 1 ) {
  	digitalWrite(HACKSPACE_OPEN_DISPLAY, HIGH);
  } else {
  	digitalWrite(HACKSPACE_OPEN_DISPLAY, LOW);
  }
  
}

void print_ldr_analog_value() {

  int ldr = analogRead(LDR_ANALOG_PIN);
  Serial.print("Analog LDR value: ");
  Serial.print(ldr);
  Serial.println();

}

//-----------------------------------------------------------------------------

void setup() {

    pinMode(DOOR_BELL_PIN, INPUT);
    pinMode(HACKSPACE_OPEN_SWITCH, INPUT);
    pinMode(HACKSPACE_OPEN_DISPLAY, OUTPUT);

    pinMode(pinDoorLock, OUTPUT);

    Serial.begin(9600);

    lcd.print("  Hello!");

    // locate devices on the bus
    Serial.print("Locating devices...");
    sensors.begin();

    num_devices = sensors.getDeviceCount();

    Serial.print("Found ");
    Serial.print(num_devices, DEC);
    Serial.println(" devices.");

    // report parasite power requirements
    Serial.print("Parasite power is: ");
    if (sensors.isParasitePowerMode()) Serial.println("ON");
    else Serial.println("OFF");

    discover_onewire_devs(num_devices);

    // set the resolution to 9 bit (Each Dallas/Maxim device
    // is capable of several different resolutions)
    for (uint8_t i=0; i<num_devices; i++) {
        sensors.setResolution(therms[i], 9);
    }

}

int val_door = 0;
long loop_count = 0;

void loop() {

    val_door = digitalRead(DOOR_BELL_PIN);
    if ( val_door ) {
        Serial.println("*** Ring Ring! ***");
        val_door = 0;
    }

	if ( loop_count % 100 == 0 ) {
		// call sensors.requestTemperatures() to issue a global temperature
		// request to all devices on the bus
		sensors.requestTemperatures(); // Send the command to get temperatures
		for (int i=0; i<num_devices; i++) {
			Serial.print("Temperature for Device ");
			Serial.print(i+1, DEC);
			Serial.print(" is: ");
			Serial.print(sensors.getTempCByIndex(i));
			Serial.println();
		}
        print_ldr_analog_value();
        Serial.println("----------------------");

		if ( is_hackspace_open() ) {
			Serial.println("Hackspace open state: 1");
			display_hackspace_open_state(1);
	    } else {
			Serial.println("Hackspace open state: 0");
			display_hackspace_open_state(0);
		}
	}

	if ( loop_count % 100 == 0 ) {
	   digitalWrite(pinDoorLock, HIGH);
	} else if ( loop_count % 100 == 500 ) {
	   digitalWrite(pinDoorLock, LOW);
	}

	loop_count++;
    delay(10);
}

// ---------------------------------------------------------------------------

