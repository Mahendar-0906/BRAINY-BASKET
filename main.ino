#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

// Replace placeholders locally; never commit real credentials.
const char* WIFI_SSID = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";
const char* BACKEND_URL = "http://YOUR_COMPUTER_IP:8081/api/iot/sensor";
const char* DEVICE_ID = "ESP32_001";
const char* ITEM_ID = "PULSE001";

void setup() {
  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) delay(500);
}

float readWeightKg() {
  // Replace with the HX711/load-cell reading for the installed hardware.
  return 2.35f;
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    StaticJsonDocument<256> document;
    document["deviceId"] = DEVICE_ID;
    document["itemId"] = ITEM_ID;
    document["sensorType"] = "weight";
    document["value"] = readWeightKg();
    document["unit"] = "kg";

    String body;
    serializeJson(document, body);
    HTTPClient client;
    client.begin(BACKEND_URL);
    client.addHeader("Content-Type", "application/json");
    int responseCode = client.POST(body);
    Serial.printf("Sensor POST response: %d\n", responseCode);
    client.end();
  }
  delay(30000);
}
