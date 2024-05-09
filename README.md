# EchoView.ai: AR Glasses for the Deaf and Hard of Hearing

![Logo](images/Logo.png)

## Introduction
EchoView.ai introduces an innovative solution designed to significantly enhance communication for the Deaf and Hard of Hearing community. Utilizing advanced technology, our glasses provide real-time speech-to-text transcription, displaying conversations directly in the user's field of vision.

## Mission Statement
Our mission is to foster community and innovation by enabling everyone to hold the key to understanding spoken interactions.

## Key Features
- **Real-Time Transcription:** Speech-to-text functionality that operates in real-time.
- **OLED Display:** Text is displayed on a discreet, built-in OLED screen within the glasses.
- **Bluetooth Connectivity:** Seamless integration with iOS devices through a custom app.
- **User-Friendly Design:** Lightweight, comfortable, and designed for everyday wear.

## System Overview
EchoView.ai glasses are powered by an ESP32-C3, featuring audio capturing and an OLED display for output. The system includes:
- ESP32-C3 for processing
- JVC HA-ET65BV Microphone and Device microphone, also compatible with MEMS microphones and various other audio inputs
- OLED display for text output
- Bluetooth module for mobile connectivity
- Birdbath Combiners/Optical Combiner (series of two-way mirrors) for projecting the image from OLED

## Installation
### Hardware Setup (Detailed information in README_hardware.md)
1. Connect the MEMS microphones to the ESP32-C3.
2. Attach the OLED display to the ESP32-C3.
3. Ensure all connections are secure and the system is powered (3.3v).

### Software Setup (Detailed information in README_software.md)
1. Clone this repository to your ESP32-C3.
2. Navigate to the /Device directory and flash the echoview_esp32_v1.ino file onto the ESP32.

## Usage
### Starting the Device
Power on the EchoView.ai glasses. The device will automatically boot up and the Raspberry Pi will begin processing input from the microphones.

### Using the Mobile App
1. Download the EchoView.ai app from the iOS App Store.
2. Press and hold the button on the side of the headset for 3 seconds until device flashes 3 times.
3. Navigate to Bluetooth in device Settings and connect to the headset.
4. Open the app and pair it with your EchoView.ai glasses.
5. Start Transcribing!

### Daily Operation
Simply wear the glasses as you would any regular glasses. Conversations will be transcribed in real-time and displayed in your field of view.

## Safety and Maintenance
- Keep the device dry and avoid exposure to extreme temperatures.
- Regularly update the software through the EchoView.ai app to ensure optimal performance and security.

![Flow Chart](images/flow_chart.png)

[![Watch the Demo](images/glasses2)](https://drive.google.com/file/d/1j2KLc6h1_2RdIPNPQ-ITHF-1azErev8u/view?usp=sharing "Watch the Demo")

For more detailed information, please refer to our [User Manual](Documentation/CopyOfPreviousReports/UserManual.pdf)

## Future Plans
EchoView.ai is exploring the integration of large language models from Hugging Face to enhance the device's capabilities. This will enable compatibility with Android devices and introduce additional languages and smart features, improving accessibility and user experience.

## Acknowledgments
Special thanks to our team members and advisors who have made significant contributions to the development and success of this project.

---
EchoView.ai – Bridging the communication gap with cutting-edge technology.
