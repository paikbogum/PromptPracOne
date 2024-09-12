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
    
    @IBOutlet var peripheralView: PeripheralView!

    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralView.recordButton.isHidden = true // 처음에는 녹화 버튼 숨김
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceConnection(_:)), name: .didConnectToPeripheral, object: nil)
    }

    @objc func handleDeviceConnection(_ notification: Notification) {
        peripheralView.recordButton.isHidden = false
        if let userInfo = notification.userInfo, let deviceName = userInfo["deviceName"] as? String {
            peripheralView.statusLabel.text = "\(deviceName)와 연결되었습니다!"
            }
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

            let serviceUUID = CBUUID(string: "FFE0")
            let service = CBMutableService(type: serviceUUID, primary: true)
            service.characteristics = [recordButtonCharacteristic!]

            peripheralManager.add(service)
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
            peripheralView.statusLabel.text = "기기 연결 중..."
        case .connected:
            peripheralView.statusLabel.text = "성공적으로 연결되었습니다!"
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("Peripheral: Central subscribed to characteristic with UUID \(characteristic.uuid)")
        
        updateStatusLabel(for: .connected) // 연결 완료 상태로 업데이트
        peripheralView.recordButton.isHidden = false
      }
    
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        guard let characteristic = recordButtonCharacteristic else {
             print("Characteristic is not set.")
             return
         }

         let valueToSend = "toggle".data(using: .utf8)
         peripheralManager.updateValue(valueToSend!, for: characteristic, onSubscribedCentrals: nil)
    }
}

enum BluetoothConnectionState {
    case disconnected
    case connecting
    case connected
}
