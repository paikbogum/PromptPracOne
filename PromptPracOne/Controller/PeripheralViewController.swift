//
//  PeripheralViewController.swift
//  PromptPracOne
//
//  Created by 백현진 on 9/4/24.
//
// 리모컨 역할

import UIKit
import CoreBluetooth

class PeripheralViewController: UIViewController, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager!
    var recordButtonCharacteristic: CBMutableCharacteristic?
    var switchCameraButtonCharacteristic: CBMutableCharacteristic?
    var zoomCharacteristic: CBMutableCharacteristic?
    var qualityCharacteristic: CBMutableCharacteristic?
    
    var scriptCharacteristic: CBMutableCharacteristic?
    var centralDeviceNameCharacteristic: CBMutableCharacteristic?
    
    @IBOutlet var peripheralView: PeripheralView!

    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralView.recordButton.isHidden = true // 처음에는 녹화 버튼 숨김
        peripheralView.setButtonUI()
        peripheralView.backgroundColor = .black
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        self.navigationController?.navigationBar.tintColor = .white
    }

    
    func updateStatusLabel(with text: String) {
        DispatchQueue.main.async {
            self.peripheralView.statusLabel.text = text
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            let characteristicUUID = CBUUID(string: "FFE1")
            recordButtonCharacteristic = CBMutableCharacteristic(type: characteristicUUID, properties: [.write, .notify], value: nil, permissions: [.writeable])
            switchCameraButtonCharacteristic = CBMutableCharacteristic(type: characteristicUUID, properties: [.write, .notify], value: nil, permissions: [.writeable])
            zoomCharacteristic = CBMutableCharacteristic(type: characteristicUUID, properties: [.write, .notify], value: nil, permissions: [.writeable])
            
            qualityCharacteristic = CBMutableCharacteristic(type: characteristicUUID, properties: [.write, .notify], value: nil, permissions: [.writeable])
            
            scriptCharacteristic = CBMutableCharacteristic(type: characteristicUUID, properties: [.notify, .write], value: nil, permissions: [.writeable])
            
            centralDeviceNameCharacteristic = CBMutableCharacteristic(type: characteristicUUID, properties: [.notify, .write], value: nil, permissions: [.writeable])
            
            

            let serviceUUID = CBUUID(string: "FFE0")
            let service = CBMutableService(type: serviceUUID, primary: true)
            service.characteristics = [recordButtonCharacteristic!]
            
            let switchService = CBMutableService(type: serviceUUID, primary: true)
            switchService.characteristics = [switchCameraButtonCharacteristic!]
            
            let zoomService = CBMutableService(type: serviceUUID, primary: true)
            zoomService.characteristics = [zoomCharacteristic!]
            
            let qualityService = CBMutableService(type: serviceUUID, primary: true)
            qualityService.characteristics = [qualityCharacteristic!]
            
            let scriptService = CBMutableService(type: serviceUUID, primary: true)
            scriptService.characteristics = [scriptCharacteristic!]
            
            let nameService = CBMutableService(type: serviceUUID, primary: true)
            nameService.characteristics = [centralDeviceNameCharacteristic!]

            peripheralManager.add(service)
            peripheralManager.add(switchService)
            peripheralManager.add(zoomService)
            peripheralManager.add(qualityService)
            peripheralManager.add(scriptService)
            peripheralManager.add(nameService)

            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])

            updateStatusLabel(for: .connecting) // 연결 시도 중 상태로 업데이트
            
            print("Peripheral: Started advertising service with UUID \(serviceUUID)")
        } else {
            print("Peripheral: Bluetooth is not powered on")
            updateStatusLabel(for: .disconnected) // 연결되지 않은 상태로 업데이트
        }
    }
    
    // 연결 상태에 따른 라벨 업데이트
    func updateStatusLabel(for state: BluetoothConnectionState) {
        switch state {
        case .disconnected:
            peripheralView.statusLabel.text = "기기 연결 대기 중..."
        case .connecting:
            peripheralView.statusLabel.text = "기기 연결 중..\n(메인기기에서 해당 기기를 찾아 연결해주세요!)"
        case .connected:
            peripheralView.statusLabel.text = "성공적으로 연결되었습니다!"
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Peripheral: Central subscribed to characteristic with UUID \(characteristic.uuid)")
    
        updateStatusLabel(for: .connected) // 연결 완료 상태로 업데이트
        peripheralView.recordButton.isHidden = false
        peripheralView.statusLabel.isHidden = true
      }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if let value = request.value, let message = String(data: value, encoding: .utf8) {
                if message.hasPrefix("script:") {
                    let script = message.replacingOccurrences(of: "script:", with: "")
                    receiveScript(scriptData: script)
                } else if message.hasPrefix("name:") {
                    let deviceName = message.replacingOccurrences(of: "name:", with: "")
                    receiveDeviceName(deviceName: deviceName)
                }
            }
        }
    }
    
    func receiveScript(scriptData: String) {
        // UI에 스크립트 표시
        self.peripheralView.scriptTextView.text = scriptData
        
        print(scriptData)

    }
    
    // 기기 이름을 수신하여 처리하는 함수
    func receiveDeviceName(deviceName: String) {

        self.navigationItem.title = "\(deviceName)과 연결됨"
        
        print("Received device name: \(deviceName)")
    }
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        guard let characteristic = recordButtonCharacteristic else {
             print("Characteristic is not set.")
             return
         }

         let valueToSend = "toggle".data(using: .utf8)
         peripheralManager.updateValue(valueToSend!, for: characteristic, onSubscribedCentrals: nil)
    }
    
    @IBAction func cameraSwitchButtonTapped(_ sender: UIButton) {
        guard let characteristic = switchCameraButtonCharacteristic else {
             print("Characteristic is not set.")
             return
         }

         let valueToSend = "toggleCamera".data(using: .utf8)
         peripheralManager.updateValue(valueToSend!, for: characteristic, onSubscribedCentrals: nil)
    }
    
    func sendZoomCommand(zoomIn: Bool) {
        guard let characteristic = zoomCharacteristic else {
             print("Characteristic is not set.")
             return
         }
        
        let command = zoomIn ? "zoomIn" : "zoomOut"
        if let valueToSend = command.data(using: .utf8) {
            peripheralManager.updateValue(valueToSend, for: characteristic, onSubscribedCentrals: nil)
        }
    }
    
    @IBAction func zoomInButtonTapped(_ sender: UIButton) {
        sendZoomCommand(zoomIn: true)
    }
    
    @IBAction func zoomOutButtonTapped(_ sender: UIButton) {
        sendZoomCommand(zoomIn: false)
    }
    
    @IBAction func qualityButtonTapped(_ sender: UIButton) {
        guard let characteristic = qualityCharacteristic else {
             print("Characteristic is not set.")
             return
         }

         let valueToSend = "toggleQuality".data(using: .utf8)
         peripheralManager.updateValue(valueToSend!, for: characteristic, onSubscribedCentrals: nil)
    }
    
}

enum BluetoothConnectionState {
    case disconnected
    case connecting
    case connected
}
