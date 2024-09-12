//
//  CentralViewController.swift
//  PromptPracOne
//
//  Created by 백현진 on 9/5/24.
//
// 녹화 장치 역할

import UIKit
import CoreBluetooth
/*
class CentralViewController: UIViewController {
    
    var centralManager: CBCentralManager!
    var discoveredPeripherals: [(peripheral: CBPeripheral, rssi: NSNumber)] = []
    
    let cellName = "CentralTableViewCell"
    let cellReuseIdentifier = "CentralTableViewCell"
    
    var overlayView: UIView! // 테이블 뷰 위에 띄울 뷰
    var activityIndicator: UIActivityIndicatorView!
    var searchingLabel: UILabel!
    
  
    @IBOutlet var centralView: CentralView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralView.setUI()
        registerXib()
        // CBCentralManager 초기화 - 이 시점에서 중앙 장치(Central)가 BLE 기능을 사용할 준비가 됨
        
        setupOverlayView() // 오버레이 뷰 설정
        
        // 블루투스 스캔 시작
        BluetoothManager.shared.startScan()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnection), name: .didConnectToPeripheral, object: nil)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleConnection() {

        dismissToBackground() // CentralViewController의 view를 투명화
    }
    
    

    
    
    // MARK: - Scanning Methods
    
    
    func setupOverlayView() {
        // 오버레이 뷰 생성 및 설정
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        
        // Activity Indicator 초기화 및 설정
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        
        // "기기 찾는 중" 라벨 초기화 및 설정
        searchingLabel = UILabel()
        searchingLabel.text = "기기 찾는 중..."
        searchingLabel.textColor = .white
        searchingLabel.textAlignment = .center
        
        // 오버레이 뷰에 인디케이터와 라벨 추가
        overlayView.addSubview(activityIndicator)
        overlayView.addSubview(searchingLabel)
        
        // 레이아웃 설정
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        searchingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor, constant: -20),
            searchingLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            searchingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10)
        ])
        
        view.addSubview(overlayView) // 오버레이 뷰를 메인 뷰에 추가
    }
    
    func startScanning() {
        discoveredPeripherals.removeAll()
        centralView.deviceTableView.reloadData()
        activityIndicator.startAnimating()
        overlayView.isHidden = false
        centralManager.scanForPeripherals(withServices: [CBUUID(string: "FFE0")], options: nil)
        print("Scanning for peripherals...")
    }
    
    func stopScanning() {
        centralManager.stopScan()
        activityIndicator.stopAnimating()
        overlayView.isHidden = true
        print("Stopped scanning.")
    }
    
    
    // MARK: - CBCentralManagerDelegate Methods
    
    func registerXib() {
        let nibName = UINib(nibName: cellName, bundle: nil)
        centralView.deviceTableView.register(nibName, forCellReuseIdentifier: cellReuseIdentifier)
        
        centralView.deviceTableView.delegate = self
        centralView.deviceTableView.dataSource = self
    }

    func dismissToBackground() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CentralViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeripherals.count
    }
    
    // 테이블 뷰: 셀 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as! CentralTableViewCell
        
        let peripheral = discoveredPeripherals[indexPath.row].peripheral
        cell.deviceName.text = "RSSI: \(discoveredPeripherals[indexPath.row].rssi)"
        
        return cell
    }
    
    // 테이블 뷰: 셀 선택 시
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = discoveredPeripherals[indexPath.row].peripheral
        BluetoothManager.shared.connectToPeripheral(peripheral)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -100 {
            BluetoothManager.shared.startScan() // 스크롤하여 새로고침 시 스캔 다시 시작
        }
    }
}
*/
