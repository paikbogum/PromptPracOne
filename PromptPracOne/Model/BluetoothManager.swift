

import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
    static let shared = BluetoothManager()
    
    var discoveredDevices: [(peripheral: CBPeripheral, rssi: NSNumber)] = []
    
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    
    var discoveredPeripheral: CBPeripheral?
    var recordButtonCharacteristic: CBCharacteristic?
    
    var isConnected: Bool = false
    
    private override init() {
        super.init()
    }
    
    func initializeCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func initializePeripheralManager() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Central Manager Delegate Methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [CBUUID(string: "FFE0")], options: nil)
        } else {
            print("Central: Bluetooth is not powered on")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // 발견된 기기를 배열에 추가
        let discoveredDevice = (peripheral: peripheral, rssi: RSSI)
        if !discoveredDevices.contains(where: { $0.peripheral.identifier == peripheral.identifier }) {
            discoveredDevices.append(discoveredDevice)
        }
        
        // 발견된 기기 리스트를 업데이트하도록 노티피케이션 전송
        NotificationCenter.default.post(name: .didDiscoverPeripheral, object: nil)
    }
    
    func connectToPeripheral(_ peripheral: CBPeripheral) {
        self.discoveredPeripheral = peripheral
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Central: Connected to peripheral")
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: "FFE0")])
        NotificationCenter.default.post(name: .didConnectToPeripheral, object: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Central: Disconnected from peripheral")
        isConnected = false
        NotificationCenter.default.post(name: .didDisconnectFromPeripheral, object: nil)
    }
    

    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics([CBUUID(string: "FFE1")], for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: "FFE1") {
                    // 여기에서 recordButtonCharacteristic을 설정합니다.
                    self.recordButtonCharacteristic = characteristic as? CBMutableCharacteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == CBUUID(string: "FFE1"), let value = characteristic.value, let command = String(data: value, encoding: .utf8), command == "toggle" {
            NotificationCenter.default.post(name: .toggleRecording, object: nil)
        }
    }
    
    // MARK: - Peripheral Manager Delegate Methods
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            let characteristicUUID = CBUUID(string: "FFE1")
            let recordButtonCharacteristic = CBMutableCharacteristic(type: characteristicUUID, properties: [.write, .notify], value: nil, permissions: [.writeable])
            
            let serviceUUID = CBUUID(string: "FFE0")
            let service = CBMutableService(type: serviceUUID, primary: true)
            service.characteristics = [recordButtonCharacteristic]
            
            peripheralManager.add(service)
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])
        } else {
            print("Peripheral: Bluetooth is not powered on")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        NotificationCenter.default.post(name: .didConnectToPeripheral, object: nil)
    }

}
