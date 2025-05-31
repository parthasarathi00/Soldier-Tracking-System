const int tempPin = A1;
const int ldrPin = A0;

float readTemperature() {
  float vout = analogRead(tempPin);
  return (vout * 500.0) / 1023.0;
}

int readHeartbeat() {
  int ldrVal = analogRead(ldrPin);
  return ldrVal / 10;
}
