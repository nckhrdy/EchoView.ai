# EchoView.ai: AR Glasses for the Deaf and Hard of Hearing
Collaborators: Nicholas Hardy, Riya Deokar, Jazmyn Walker, Hassan Hijazi, Marybel Boujaoude

## Introduction
EchoView.ai introduces an innovative solution designed to significantly enhance communication for the Deaf and Hard of Hearing community. Utilizing advanced AR technology, our glasses provide real-time speech-to-text transcription, displaying conversations directly in the user's field of vision.

## Key Features
- **Real-Time Transcription:** Speech-to-text functionality that operates in real-time.
- **OLED Display:** Text is displayed on a discreet, built-in OLED screen within the glasses.
- **Bluetooth Connectivity:** Seamless integration with iOS devices through a custom app.
- **User-Friendly Design:** Lightweight, comfortable, and designed for everyday wear.

## System Overview
EchoView.ai glasses are powered by an ESP32-C3, featuring MEMS microphones for audio input and an OLED display for output. The system includes:
- ESP32-C3 for processing
- MEMS microphones for audio capture
- OLED display for text output
- Bluetooth module for mobile connectivity

## Installation
### Hardware Setup
1. Connect the MEMS microphones to the ESP32-C3.
2. Attach the OLED display to the ESP32-C3.
3. Ensure all connections are secure and the system is powered (3.3v).

### Software Setup
1. Clone this repository to your ESP32-C3.
2. Navigate to the /Device directory and flash the echoview_esp32_v1.ino file onto the ESP32.


## Usage
### Starting the Device
Power on the EchoView.ai glasses. The device will automatically boot up and the Raspberry Pi will begin processing input from the microphones.

### Using the Mobile App
1. Download the EchoView.ai app from the iOS App Store.
2. Press and hold the button on the side of the headset for 3 seconds until device flashes 3 times
3. Navitage to Bluetooth in device Settings and connect to headset
3. Open the app and pair it with your EchoView.ai glasses
4. Start Transcribing!

### Daily Operation
Simply wear the glasses as you would any regular glasses. Conversations will be transcribed in real-time and displayed in your field of view.

## Safety and Maintenance
- Keep the device dry and avoid exposure to extreme temperatures.
- Regularly update the software through the EchoView.ai app to ensure optimal performance and security.

