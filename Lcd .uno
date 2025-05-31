LiquidCrystal_I2C lcd(0x27, 16, 2);

void setupLCD() {
  lcd.begin();
  lcd.backlight();
  lcd.clear();
  lcd.print("Searching");
  lcd.setCursor(0, 1);
  lcd.print("Network...");
  delay(3000);
}

void displayMessage(String line1, String line2 = "") {
  lcd.clear();
  lcd.print(line1);
  lcd.setCursor(0, 1);
  lcd.print(line2);
}
