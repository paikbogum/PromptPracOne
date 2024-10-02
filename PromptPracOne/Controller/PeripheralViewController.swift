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
    
    let singletonMan = LanguageManager.shared
    
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
            // 고유한 특성 UUID 정의
            let recordCharacteristicUUID = CBUUID(string: "FFE1")
            let switchCameraCharacteristicUUID = CBUUID(string: "FFE2")
            let zoomCharacteristicUUID = CBUUID(string: "FFE3")
            let qualityCharacteristicUUID = CBUUID(string: "FFE4")
            let scriptCharacteristicUUID = CBUUID(string: "FFE5")
            let deviceNameCharacteristicUUID = CBUUID(string: "FFE6")
            
            // 특성 정의
            recordButtonCharacteristic = CBMutableCharacteristic(type: recordCharacteristicUUID, properties: [.write, .notify], value: nil, permissions: [.writeable])
            switchCameraButtonCharacteristic = CBMutableCharacteristic(type: switchCameraCharacteristicUUID, properties: [.write, .notify], value: nil, permissions: [.writeable])
            zoomCharacteristic = CBMutableCharacteristic(type: zoomCharacteristicUUID, properties: [.write, .notify], value: nil, permissions: [.writeable])
            qualityCharacteristic = CBMutableCharacteristic(type: qualityCharacteristicUUID, properties: [.write, .notify], value: nil, permissions: [.writeable])
            scriptCharacteristic = CBMutableCharacteristic(type: scriptCharacteristicUUID, properties: [.notify, .write], value: nil, permissions: [.writeable])
            centralDeviceNameCharacteristic = CBMutableCharacteristic(type: deviceNameCharacteristicUUID, properties: [.notify, .write], value: nil, permissions: [.writeable])

            // 고유한 서비스 UUID 정의
            let serviceUUID = CBUUID(string: "FFE0")
            let service = CBMutableService(type: serviceUUID, primary: true)
            
            // 특성을 서비스에 추가
            service.characteristics = [
                recordButtonCharacteristic!,
                switchCameraButtonCharacteristic!,
                zoomCharacteristic!,
                qualityCharacteristic!,
                scriptCharacteristic!,
                centralDeviceNameCharacteristic!
            ]
            
            // 서비스 추가
            peripheralManager.add(service)
            
            // 광고 시작
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
            peripheralView.statusLabel.text = singletonMan.setLanguageText(key: "statusDisconnected")
        case .connecting:
            peripheralView.statusLabel.text = singletonMan.setLanguageText(key: "statusConnecting")
        case .connected:
            peripheralView.statusLabel.text = singletonMan.setLanguageText(key: "statusConnected")
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
