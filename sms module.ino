#include "config.h"

SoftwareSerial Gsm(7, 8);

void setupGSM() {
  Gsm.begin(9600);
  delay(2000);
  Gsm.print("AT+CMGF=1\r"); 
  delay(100);
  Gsm.print("AT+CNMI=2,2,0,0,0\r");
  delay(100);
}

void sendSMS(float lat, float lon, float temp, int heartbeat, const char* message) {
  Gsm.print("AT+CMGF=1\r"); 
  delay(400);
  Gsm.print("AT+CMGS=\"");
  Gsm.print(PHONE_NUMBER);
  Gsm.println("\"");

  Gsm.println(message);
  Gsm.println(BATTALION_ID);
  Gsm.print("Temperature: ");
  Gsm.println(temp);
  Gsm.print("Heartbeat: ");
  Gsm.println(heartbeat);
  Gsm.print("http://maps.google.com/maps?q=loc:");
  Gsm.print(lat == TinyGPS::GPS_INVALID_F_ANGLE ? 0.0 : lat, 6);
  Gsm.print(",");
  Gsm.println(lon == TinyGPS::GPS_INVALID_F_ANGLE ? 0.0 : lon, 6);

  delay(200);
  Gsm.println((char)26); 
  delay(10000);
}
