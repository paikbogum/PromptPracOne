import CoreBluetooth
import UIKit

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
    static let shared = BluetoothManager()

    var receiveScript: String?
    
    var discoveredDevices: [(peripheral: CBPeripheral, rssi: NSNumber)] = []
    var connectedDeviceName: String? // 연결된 기기의 이름을 저장
    
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    
    var discoveredPeripheral: CBPeripheral?
    var recordButtonCharacteristic: CBCharacteristic?
    var switchButtonCharacteristic: CBCharacteristic?
    var qualityButtonCharacteristic: CBCharacteristic?
    
    var scriptCharacteristic: CBCharacteristic?

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
        switch central.state {
         case .poweredOn:
             // 블루투스가 켜져 있을 때 스캔 시작
             print("Central: Bluetooth is powered on, starting scan.")
             centralManager.scanForPeripherals(withServices: [CBUUID(string: "FFE0")], options: nil)
             
         case .poweredOff:
             // 블루투스가 꺼져 있을 때 사용자에게 알림
             print("Central: Bluetooth is powered off.")
             showAlertToEnableBluetooth() // 블루투스를 켜달라는 알림
             
         case .resetting:
             print("Central: Bluetooth is resetting.")
             
         case .unauthorized:
             print("Central: Unauthorized to use Bluetooth.")
             showBluetoothAccessAlert() // 블루투스 권한 요청 알림
             
         case .unsupported:
             print("Central: Bluetooth is not supported on this device.")
             
         case .unknown:
             print("Central: Bluetooth state is unknown.")
             
         @unknown default:
             print("Central: A new state is available that is not handled.")
         }
    }
    
    // 블루투스를 켜달라는 알림을 사용자에게 표시하는 함수
    func showAlertToEnableBluetooth() {
        let alert = UIAlertController(title: "Bluetooth is Off", message: "Please turn on Bluetooth to connect to devices.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        // 현재의 뷰 컨트롤러에서 알림을 표시
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    // 블루투스 접근 권한이 없는 경우 알림
    func showBluetoothAccessAlert() {
        let alert = UIAlertController(title: "Bluetooth Access Required", message: "This app needs Bluetooth access to connect to devices.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default) { _ in
            // 사용자가 '설정'으로 이동할 수 있게 링크 제공
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true, completion: nil)
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
        connectedDeviceName = peripheral.name
        isConnected = true
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
    
    func sendScript(_ script: String) {
        guard let characteristic = scriptCharacteristic, let data = script.data(using: .utf8) else {
            return
        }
        discoveredPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: "FFE1") {
                    // 여기에서 recordButtonCharacteristic을 설정합니다.
                    self.recordButtonCharacteristic = characteristic as? CBMutableCharacteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                    
                    self.switchButtonCharacteristic = characteristic as? CBMutableCharacteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                    
                    self.qualityButtonCharacteristic = characteristic as? CBMutableCharacteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                    
                    scriptCharacteristic = characteristic
                    sendScript(receiveScript ?? "no script")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == CBUUID(string: "FFE1"), let value = characteristic.value, let command = String(data: value, encoding: .utf8) {
            switch command {
            case "toggle":
                NotificationCenter.default.post(name: .toggleRecording, object: nil)
            case "toggleCamera":
                NotificationCenter.default.post(name: .toggleCamera, object: nil)
            case "zoomIn":
                NotificationCenter.default.post(name: .didReceiveZoomCommand, object: nil, userInfo: ["zoomIn": true])
            case "zoomOut":
                NotificationCenter.default.post(name: .didReceiveZoomCommand, object: nil, userInfo: ["zoomIn": false])
            case "toggleQuality":
                NotificationCenter.default.post(name: .toggleQuality, object: nil)
            default:
                break
            }
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
