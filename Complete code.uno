#include <TinyGPS.h>
#include <SoftwareSerial.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

// LCD Display (I2C)
LiquidCrystal_I2C lcd(0x27, 16, 2);

// GSM module connected on pins 7 (RX) and 8 (TX)
SoftwareSerial Gsm(7, 8);

// Replace this with the actual phone number to receive SMS
char phone_no[] = "+91XXXXXXXXXX";

// GPS object
TinyGPS gps;

// Pins
const int tempSensorPin = A1;
const int ldrPin = A0;
const int buttonPin = 6;

// Variables
String textMessage;
float tempc;
float vout;

void setup() {
  Gsm.begin(9600);
  delay(2000);

  // GSM initialization
  Gsm.print("AT+CMGF=1\r"); // Set SMS to text mode
  delay(100);
  Gsm.print("AT+CNMI=2,2,0,0,0\r"); // Direct SMS data to serial output
  delay(100);

  // Pin configuration
  pinMode(buttonPin, INPUT_PULLUP);
  pinMode(tempSensorPin, INPUT);
  pinMode(ldrPin, INPUT);

  // LCD setup
  lcd.begin();
  lcd.backlight();
  lcd.clear();
  lcd.print("Searching ");
  lcd.setCursor(0, 1);
  lcd.print("Network....... ");
  delay(3000);
}

void loop() {
  lcd.clear();
  lcd.print("Soldier Tracking");
  lcd.setCursor(0, 1);
  lcd.print("System...!!");
  delay(100);

  // Parse GPS data
  for (unsigned long start = millis(); millis() - start < 1000;) {
    while (Gsm.available()) {
      char c = Gsm.read(); // GPS data through GSM port
      gps.encode(c);
    }
  }

  // Read sensors
  vout = analogRead(tempSensorPin);
  vout = (vout * 500) / 1023;
  tempc = vout;
  int ldrStatus = analogRead(ldrPin);

  // Check for incoming SMS
  if (Gsm.available() > 0) {
    textMessage = Gsm.readString();
    textMessage.toUpperCase();
    delay(10);
  }

  // If the SMS contains "LOCAL", send location & sensor info
  if (textMessage.indexOf("LOCAL") >= 0) {
    lcd.clear();
    lcd.print("Message Received");
    delay(2000);
    lcd.clear();
    lcd.print("Getting Location");
    delay(2000);

    float flat, flon;
    unsigned long age;
    gps.f_get_position(&flat, &flon, &age);

    sendSMS(
      "Asheesh, Battalion No. 1233456\n" +
      String("Temperature: ") + String(tempc) +
      "\nHeartbeat: " + String(ldrStatus / 10) +
      "\nhttp://maps.google.com/maps?q=loc:" + String(flat, 6) + "," + String(flon, 6)
    );

    lcd.clear();
    lcd.print("Location Sent");
    delay(2000);
    textMessage = ""; // Clear received text
  }

  // Button Press Alert
  if (isButtonPressed()) {
    float flat, flon;
    unsigned long age;
    gps.f_get_position(&flat, &flon, &age);

    sendSMS(
      "⚠️ EMERGENCY! Soldier needs help!\nAsheesh, Battalion No. 1233456\n" +
      String("Temperature: ") + String(tempc) +
      "\nHeartbeat: " + String(ldrStatus / 10) +
      "\nhttp://maps.google.com/maps?q=loc:" + String(flat, 6) + "," + String(flon, 6)
    );

    lcd.clear();
    lcd.print("Alert Sent");
    delay(2000);
  }
}

// Utility: Button press (active LOW)
bool isButtonPressed() {
  return digitalRead(buttonPin) == LOW;
}

// Utility: Send SMS using GSM
void sendSMS(String message) {
  Gsm.print("AT+CMGF=1\r");
  delay(400);
  Gsm.print("AT+CMGS=\"");
  Gsm.print(phone_no);
  Gsm.println("\"");
  delay(200);
  Gsm.println(message);
  Gsm.println((char)26); // End message with Ctrl+Z
  delay(10000);
}
