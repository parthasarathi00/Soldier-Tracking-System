#include <TinyGPS.h>

TinyGPS gps;

bool getGPSLocation(float* flat, float* flon, unsigned long* age) {
  bool newData = false;
  for (unsigned long start = millis(); millis() - start < 1000;) {
    while (Serial.available()) {
      char c = Serial.read();
      if (gps.encode(c)) newData = true;
    }
  }
  if (newData) {
    gps.f_get_position(flat, flon, age);
    return true;
  }
  return false;
}
