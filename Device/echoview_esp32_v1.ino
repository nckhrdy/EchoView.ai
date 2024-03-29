#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels
#define OLED_RESET     -1 // Reset pin # (or -1 if sharing Arduino reset pin)
#define SCREEN_ADDRESS 0x3D ///< See datasheet for Address; 0x3D for 128x64, 0x3C for 128x32

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

#define SERVICE_UUID                "ABC0FCC1-2FC3-44B7-94A8-A08D0A0A5079"
#define CHARACTERISTIC_INPUT_UUID   "A1AB2C55-7914-4140-B85B-879C5E252FE5"
#define CHARACTERISTIC_OUTPUT_UUID  "A43954A4-A6CC-455C-825C-499190CE7DB0"

BLECharacteristic *pOutputCharacteristic;

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) override {
      Serial.println("Client Connected");
    }

    void onDisconnect(BLEServer* pServer) override {
      Serial.println("Client Disconnected");
      BLEDevice::startAdvertising(); // Ensure we're still discoverable after disconnect.
    }
};

class MyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) override {
      std::string value = pCharacteristic->getValue();

      if (!value.empty()) {
        Serial.print("Received Value: ");
        String text = ""; // Create an empty string to hold incoming text
        for (auto &it : value) {
          Serial.print(it);
          text += it; // Append received characters to the string
        }
        Serial.println();

        // Update OLED display with received text
        display.clearDisplay();
        display.setTextSize(1);      // Normal 1:1 pixel scale
        display.setTextColor(SSD1306_WHITE); // Draw white text
        display.setCursor(0,0);     // Start at top-left corner
        display.println(text); // Print the received text
        display.display();          // Show the display buffer on the screen

        // Optionally, echo the value back to the client as a confirmation
        pOutputCharacteristic->setValue(value);
        pOutputCharacteristic->notify();
      }
    }
};

void setup() {
  Serial.begin(115200);
  
  // Initialize OLED display
  if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    for(;;); // Don't proceed, loop forever
  }
  display.display(); // Show initial display buffer (splash screen or blank)
  delay(2000); // Pause for 2 seconds
  display.clearDisplay(); // Clear the buffer

  // Initialize BLE
  BLEDevice::init("ESP32-C3-QT-PY");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);

  BLECharacteristic *pInputCharacteristic = pService->createCharacteristic(
                                           CHARACTERISTIC_INPUT_UUID,
                                           BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_WRITE_NR);
  pInputCharacteristic->setCallbacks(new MyCallbacks());

  pOutputCharacteristic = pService->createCharacteristic(
                                         CHARACTERISTIC_OUTPUT_UUID,
                                         BLECharacteristic::PROPERTY_NOTIFY);
  pOutputCharacteristic->addDescriptor(new BLE2902());

  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  BLEDevice::startAdvertising();

  Serial.println("Waiting for a client connection to notify...");
}

void loop() {
  // No operation needed in the loop for this example.
  delay(1000);
}
