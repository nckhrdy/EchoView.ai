import CoreBluetooth
import Foundation

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    public var connectedPeripheral: CBPeripheral?
    private var inputCharacteristic: CBCharacteristic?
    @Published var isConnected = false
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var isScanning = false

    let serviceUUID = CBUUID(string: "ABC0FCC1-2FC3-44B7-94A8-A08D0A0A5079")
    let inputCharacteristicUUID = CBUUID(string: "A1AB2C55-7914-4140-B85B-879C5E252FE5")
    let outputCharacteristicUUID = CBUUID(string: "A43954A4-A6CC-455C-825C-499190CE7DB0")

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        if centralManager.state == .poweredOn {
            isScanning = true
            discoveredPeripherals.removeAll()
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
            print("Scanning started...")
        } else {
            print("Bluetooth is not powered on.")
        }
    }

    func stopScanning() {
        if isScanning {
            centralManager.stopScan()
            isScanning = false
            print("Scanning stopped.")
        }
    }

    func connect(to peripheral: CBPeripheral) {
        if centralManager.state == .poweredOn {
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
            connectedPeripheral = peripheral
            peripheral.delegate = self
        } else {
            print("Bluetooth is not powered on.")
        }
    }

    func disconnect() {
        if let connectedPeripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(connectedPeripheral)
        }
    }

    // MARK: CBCentralManagerDelegate Methods
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("Bluetooth is powered off.")
        case .poweredOn:
            print("Bluetooth is powered on.")
            startScanning()
        case .resetting:
            print("Bluetooth is resetting.")
        case .unauthorized:
            print("Bluetooth is unauthorized.")
        case .unsupported:
            print("Bluetooth is unsupported.")
        case .unknown:
            print("Bluetooth state is unknown.")
        @unknown default:
            print("Unknown Bluetooth state.")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredPeripherals.append(peripheral)
            print("Discovered \(peripheral.name ?? "Unknown Device")")
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown Device")")
        isConnected = true
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown Device") with error: \(error?.localizedDescription ?? "No error")")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "Unknown Device")")
        isConnected = false
        connectedPeripheral = nil
    }

    // MARK: CBPeripheralDelegate Methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services, error == nil else {
            print("Error discovering services: \(error?.localizedDescription ?? "No error")")
            return
        }
        for service in services {
            peripheral.discoverCharacteristics([inputCharacteristicUUID, outputCharacteristicUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics, error == nil else {
            print("Error discovering characteristics: \(error?.localizedDescription ?? "No error")")
            return
        }
        for characteristic in characteristics {
            if characteristic.uuid == inputCharacteristicUUID {
                inputCharacteristic = characteristic
                print("Input characteristic found.")
            } else if characteristic.uuid == outputCharacteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
                print("Output characteristic found. Notifications enabled.")
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error writing to characteristic: \(error.localizedDescription)")
        } else {
            print("Successfully wrote to characteristic.")
        }
    }

    func sendMessage(_ message: String) {
        guard let peripheral = connectedPeripheral,
              let characteristic = inputCharacteristic,
              let messageData = message.data(using: .utf8) else {
            print("Cannot send message: Peripheral or characteristic not available, or message encoding failed.")
            return
        }
        print("Attempting to send message: \(message)")
        peripheral.writeValue(messageData, for: characteristic, type: .withResponse)
    }
    
    // Manual test message send functionality
    func manualSendMessageTest() {
        print("Manual test message send initiated.")
        sendMessage("Test message from manual trigger")
    }
}
