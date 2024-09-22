//
//  RecordingViewController.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/22/24.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var recordingView: RecordingView!
    // 클로저 프로퍼티 정의
    var onScriptReceived: (() -> Void)?
    
    let halfSizeTransitioningDelegate = HalfSizeTransitioningDelegate()
    
    var isContinuousScrollEnabled: Bool = false // 기본 모드는 끊어서 스크롤
    var scrollSpeed: TimeInterval = 6.0 // 기본 스크롤 속도
    var backgroundAlpha: CGFloat = 0.7 // 기본 배경 투명도
    var fontSize: CGFloat = 17.0 // 기본 폰트 사이즈
    
    var recordingManager = RecordingManager()
    var captureSession: AVCaptureSession!
    
    var zoomSlider: UISlider!
    var minusLabel: UILabel!
    var plusLabel: UILabel!
    var hideSliderTimer: Timer?
    
    private var progressBar: UIProgressView!
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var currentCameraPosition: AVCaptureDevice.Position = .back
    var isHD60Selected = false // 현재 선택된 프레임 속도를 추적하는 변수
    
    
    //overlayView
    var overlayView: UIView!
    var discoveredDevices: [String] = []
    var deviceTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSession()
        setupZoomSlider()
        setupProgressBar()
        onScriptReceived?()
        recordingView.bluetoothButton.tintColor = .white

        // Notification 설정
        NotificationCenter.default.addObserver(self, selector: #selector(toggleRecording), name: .toggleRecording, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didConnectToPeripheral), name: .didConnectToPeripheral, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didConnectToPeripheral), name: .didDisconnectFromPeripheral, object: nil)
        
        // UIPanGestureRecognizer 설정
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        recordingView.scriptTextView.addGestureRecognizer(panGesture)
        
        // UIPinchGestureRecognizer 설정
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        recordingView.previewView.addGestureRecognizer(pinchGesture)
        
        recordingView.qualityButton.addTarget(self, action: #selector(qualityButtonTapped), for: .touchUpInside)
        
        // NotificationCenter를 사용하여 슬라이더 값 변경을 감지
        NotificationCenter.default.addObserver(self, selector: #selector(handleFontSizeChange(_:)), name: .scriptViewFontSizeChanged, object: nil)
        
        // NotificationCenter를 사용하여 SettingViewController에서 전달된 스크롤 옵션을 감지
        NotificationCenter.default.addObserver(self, selector: #selector(handleScrollOptionChanged(_:)), name: .scrollOptionChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBackgroundAlphaChanged(_:)), name: .backgroundAlphaChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleScrollSpeedChanged(_:)), name: .scrollSpeedChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView), name: .didDiscoverPeripheral, object: nil)
        
        // 카메라 전환 명령을 받기 위한 Notification
        NotificationCenter.default.addObserver(self, selector: #selector(switchCameraTapped(_:)), name: .toggleCamera, object: nil)
        // 줌 제어 명령을 받기 위한 Notification
        
        // NotificationCenter를 사용해 블루투스로부터 줌 명령을 수신
        NotificationCenter.default.addObserver(self, selector: #selector(handleZoomCommand(_:)), name: .didReceiveZoomCommand, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(qualityButtonTapped), name: .toggleQuality, object: nil)
        
        // 장치 방향 변경 감지
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .toggleRecording, object: nil)
        NotificationCenter.default.removeObserver(self, name: .toggleCamera, object: nil)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 프레임을 업데이트하여 previewView의 크기와 맞춥니다.
        videoPreviewLayer?.frame = recordingView.previewView.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 화면이 나타난 후에 방향을 업데이트
        updatePreviewLayerRotation()
        // 프레임을 업데이트하여 previewView의 크기와 맞춥니다.
        videoPreviewLayer?.frame = recordingView.previewView.bounds
    }
    
    @objc func updateTableView() {
        if let deviceTableView = deviceTableView {
            deviceTableView.reloadData()
        }
    }
    
    
    // UITextView의 실제 표시 줄 수를 계산하는 메서드
    func prepareScriptLines() {
        // 먼저 UITextView에 전체 텍스트를 설정
        recordingView.scriptTextView.text = recordingManager.scriptText
        BluetoothManager.shared.receiveScript = recordingManager.scriptText
        
        // 실제로 몇 줄로 표시되는지 계산하여 scriptLines 배열에 추가
        let layoutManager = recordingView.scriptTextView.layoutManager
        let _ = recordingView.scriptTextView.textContainer
        let textStorage = recordingView.scriptTextView.textStorage
        
        // 줄 수 계산
        var scriptLines: [String] = []
        var index = 0
        while index < layoutManager.numberOfGlyphs {
            var lineRange = NSRange(location: 0, length: 0)
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            
            // 각 줄의 텍스트를 scriptLines에 추가
            let lineText = (textStorage.string as NSString).substring(with: lineRange)
            scriptLines.append(lineText.trimmingCharacters(in: .whitespacesAndNewlines))
            
            index = NSMaxRange(lineRange)
        }
        
        // RecordingManager에 scriptLines 전달
        recordingManager.scriptLines = scriptLines
        print("Calculated scriptLines: \(recordingManager.scriptLines.count) lines")
    }
    
    func setAllIn() {
         loadSettings {
             self.setupUI()
             self.prepareScriptLines()
             self.updateScriptView()
         }
     }
    
    func setupUI() {
        recordingView.setupCountdownLabel()
        recordingView.setInitialButtonUI()
        recordingView.setScriptViewUI()
        recordingView.setCameraQuality()
        recordingView.recordingTimeLabel.text = ""
        recordingView.scriptTextView.isEditable = false
        recordingView.backgroundColor = .black
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func setupSession() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        
        // 비디오 입력 설정
        guard let camera = getCamera(for: currentCameraPosition) else {
            print("Error: No video camera available")
            return
        }
    
        do {
            let videoInput = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
        } catch {
            print("Error setting up camera input: \(error.localizedDescription)")
            return
        }
        
        // 오디오 입력 설정
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            print("Error: No audio device available")
            return
        }
        
        do {
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            if captureSession.canAddInput(audioInput) {
                captureSession.addInput(audioInput)
            }
        } catch {
            print("Error setting up audio input: \(error.localizedDescription)")
            return
        }
        
        // 비디오 아웃풋 설정
        recordingManager.videoOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(recordingManager.videoOutput!) {
            captureSession.addOutput(recordingManager.videoOutput!)
        }
        
        captureSession.commitConfiguration()
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = recordingView.previewView.bounds
        recordingView.previewView.layer.addSublayer(videoPreviewLayer!)
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    @IBAction func switchCameraTapped(_ sender: UIButton) {
        
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        
        captureSession.beginConfiguration()
        
        captureSession.inputs.forEach { input in
            captureSession.removeInput(input)
        }
        
        guard let newCamera = getCamera(for: currentCameraPosition) else {
            print("Error: No video camera available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: newCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error setting up camera input: \(error.localizedDescription)")
            return
        }
        
        captureSession.commitConfiguration()
        
        let minFrameDuration = newCamera.activeVideoMinFrameDuration
        let maxFrameDuration = newCamera.activeVideoMaxFrameDuration
        // 프레임 레이트 계산 (duration을 프레임 수로 변환)
        let minFrameRate = Int32(1.0 / CMTimeGetSeconds(minFrameDuration))
        let maxFrameRate = Int32(1.0 / CMTimeGetSeconds(maxFrameDuration))
        
        // 최소 프레임 레이트와 최대 프레임 레이트가 같은 경우, 하나의 값만 출력
        if minFrameRate == maxFrameRate {
            print("Current frame rate: \(minFrameRate) FPS")
            // 버튼의 텍스트 업데이트
            DispatchQueue.main.async {
                self.recordingView.qualityButton.setTitle("HD \(minFrameRate)", for: .normal)
            }
        }
        
    }
    
    // 장치 방향 변경 감지 핸들러
    @objc func handleDeviceOrientationChange() {
        updatePreviewLayerRotation()
    }
    
    // 미리보기 레이어의 회전 각도 업데이트
    func updatePreviewLayerRotation() {
        guard let videoPreviewLayer = videoPreviewLayer else { return }

        let currentOrientation = getCurrentInterfaceOrientation()
        var rotationAngle: CGFloat = 0

        switch currentOrientation {
        case .landscapeLeft:
            rotationAngle = CGFloat(Double.pi / 2)
        case .landscapeRight:
            rotationAngle = -CGFloat(Double.pi / 2)
        case .portraitUpsideDown:
            rotationAngle = CGFloat(Double.pi)
        case .portrait, .unknown:
            rotationAngle = 0
        default:
            rotationAngle = 0
        }

        // 회전 각도를 미리보기 레이어에 적용
        videoPreviewLayer.setAffineTransform(CGAffineTransform(rotationAngle: rotationAngle))
    }
    
    // 현재 인터페이스 방향을 얻는 메서드
    func getCurrentInterfaceOrientation() -> UIInterfaceOrientation {
        if let windowScene = view.window?.windowScene {
            return windowScene.interfaceOrientation
        }
        return .unknown
    }
    
 
    
    @objc func toggleRecording() {
        guard let videoOutput = recordingManager.videoOutput else {
            print("Error: videoOutput is not initialized")
            return
        }
        
        if videoOutput.isRecording {
            print("Stopping recording...")
            stopRecording()
        } else if recordingView.countdownLabel.isHidden {
            recordingView.recordButton.isHidden = true
            print("Starting countdown...")
            startCountdown()
            recordingView.setStopButtonUI()
        }
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        guard let videoOutput = recordingManager.videoOutput else {
            print("Error: videoOutput is not initialized")
            return
        }
        
        if videoOutput.isRecording {
            print("Stopping recording...")
            stopRecording()
        } else if recordingView.countdownLabel.isHidden {
            recordingView.recordButton.isHidden = true
            print("Starting countdown...")
            startCountdown()
            recordingView.setStopButtonUI()
        }
    }
    
    @IBAction func settingButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController {
            settingsVC.modalPresentationStyle = .custom
            settingsVC.transitioningDelegate = halfSizeTransitioningDelegate
            present(settingsVC, animated: true, completion: nil)
        }
    }
    
    func startCountdown() {
        var countdown = 3
        recordingView.countdownLabel.isHidden = false
        recordingView.countdownLabel.text = "\(countdown)"
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            countdown -= 1
            
            UIView.animate(withDuration: 0.5, animations: {
                self.recordingView.countdownLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.recordingView.countdownLabel.alpha = 0.0
            }, completion: { _ in
                self.recordingView.countdownLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.recordingView.countdownLabel.alpha = 1.0
                self.recordingView.countdownLabel.text = "\(countdown)"
            })
            
            if countdown == 0 {
                timer.invalidate()
                self.recordingView.countdownLabel.isHidden = true
                self.startRecording()
            }
        }
    }
    
    func startRecording() {
        recordingView.recordButton.isHidden = false
        recordingView.qualityButton.isHidden = true
        progressBar.isHidden = false
        
        progressBar.setProgress(0.0, animated: false) // 시작 시 프로그레스 바 초기화
        
        let outputPath = NSTemporaryDirectory() + "output.mov"
        let outputFileURL = URL(fileURLWithPath: outputPath)
        
        if FileManager.default.fileExists(atPath: outputFileURL.path) {
            do {
                try FileManager.default.removeItem(at: outputFileURL)
            } catch {
                print("Error removing file: \(error.localizedDescription)")
                return
            }
        }
        recordingManager.startRecording(with: outputFileURL, delegate: self)
        recordingManager.recordingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRecordingTime), userInfo: nil, repeats: true)
        
        if isContinuousScrollEnabled {
            startScrollFunction2()
            print("Function 2 Script scrolling started.")
        } else {
            if recordingManager.scriptLines.count > 5 {
                recordingManager.scriptTimer = Timer.scheduledTimer(timeInterval: scrollSpeed, target: self, selector: #selector(scrollScript), userInfo: nil, repeats: true)
                print("Function 1 Script scrolling started.")
            } else {
                scrollScript()
            }
        }
    }
    
    func stopRecording() {
        recordingManager.stopRecording()
        recordingView.recordingTimeLabel.text = ""
        recordingView.setInitialButtonUI()
        recordingView.qualityButton.isHidden = false
        progressBar.isHidden = true
        resetScriptView()
        progressBar.setProgress(0.0, animated: false)
    }
    
    
    func resetScriptView() {
        recordingManager.resetScriptIndex()
        updateScriptView()
    }
    
    func updateScriptView() {
        // 강제로 레이아웃을 업데이트한 후 다시 스크롤 위치를 설정
        recordingView.scriptTextView.backgroundColor = UIColor.black.withAlphaComponent(backgroundAlpha)
        
        if isContinuousScrollEnabled {
            // 스크립트 뷰의 스크롤 위치를 맨 위로 초기화
            recordingView.scriptTextView.textAlignment = .center
            recordingView.scriptTextView.layoutIfNeeded()
            recordingView.scriptTextView.setContentOffset(CGPoint.zero, animated: false)
            recordingView.scriptTextView.font = UIFont.systemFont(ofSize: fontSize)
            
            
        } else {
            let scriptText = recordingManager.getVisibleScriptLines()
            
            // NSAttributedString을 사용하여 텍스트에 스타일 적용
            let attributedText = NSMutableAttributedString()
            
            let lines = scriptText.components(separatedBy: "\n")
            
            for (index, line) in lines.enumerated() {
                if index == 0 {
                    // 첫 번째 줄에 하이라이트 적용
                    let highlightedAttributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.red,
                        .font: UIFont.boldSystemFont(ofSize: fontSize)
                    ]
                    let highlightedLine = NSAttributedString(string: line + "\n", attributes: highlightedAttributes)
                    attributedText.append(highlightedLine)
                } else {
                    // 나머지 줄은 기본 스타일 적용
                    let normalAttributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor.white,
                        .font: UIFont.systemFont(ofSize: fontSize)
                    ]
                    let normalLine = NSAttributedString(string: line + "\n", attributes: normalAttributes)
                    attributedText.append(normalLine)
                }
            }
            
            // UITextView에 적용
            recordingView.scriptTextView.attributedText = attributedText
            recordingView.scriptTextView.textAlignment = .center
        }
    }
    
    @objc func updateRecordingTime() {
        let time = recordingManager.getRecordingElapsedTime()
        recordingView.updateRecordingTimeLabel(with: time)
    }
    
    
    func startScrollFunction2() {
        // 스크립트의 줄 수 계산
        let lineCount = recordingManager.scriptLines.count
        
        // 기본 6초 * 줄 수를 계산한 타임 인터벌로 설정
        let scrollDuration = scrollSpeed * Double(lineCount)
        
        scrollScriptAutoVer(scrollDuration: scrollDuration)
    }
    
    @objc func scrollScript() {
        if recordingManager.updateScriptIndex() {
            updateScriptView()
            
            // 진행도를 스크립트의 현재 줄 수에 따라 계산
            let progress = Float(recordingManager.currentDisplayStartIndex) / Float(recordingManager.scriptLines.count)
            progressBar.setProgress(progress, animated: true)
            
        } else {
            print("Script scrolling finished.")
            progressBar.setProgress(1.0, animated: true) // 완료 시 프로그레스 바를 100%로 설정
        }
    }
    
    @objc func scrollScriptAutoVer(scrollDuration: TimeInterval) {
        let totalScrollHeight = recordingView.scriptTextView.contentSize.height - recordingView.scriptTextView.bounds.height
        
        UIView.animate(withDuration: scrollDuration, delay: 0, options: .curveLinear, animations: {
            self.recordingView.scriptTextView.setContentOffset(CGPoint(x: .zero, y: totalScrollHeight), animated: false)
            self.updateProgressBar()
        }, completion: { finished in
            if finished {
                print("Script scrolling finished.")
                self.progressBar.setProgress(1.0, animated: true) // 완료 시 프로그레스 바를 100%로 설정
                print("Progress bar reached 100%.")
            }
        })
    }
    
    func showAllScriptText() {
        recordingView.scriptTextView.text = recordingManager.scriptText
        recordingView.scriptTextView.textAlignment = .center
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let scriptTextView = gesture.view as? UITextView else { return }
        
        let translation = gesture.translation(in: view)
        
        // Auto Layout 비활성화
        scriptTextView.translatesAutoresizingMaskIntoConstraints = true
        
        // 새로운 위치 계산
        var newCenter = CGPoint(x: scriptTextView.center.x + translation.x,
                                y: scriptTextView.center.y + translation.y)
        
        // previewView의 프레임 가져오기
        let previewFrame = recordingView.previewView.frame
        let halfWidth = scriptTextView.frame.width / 2
        let halfHeight = scriptTextView.frame.height / 2
        
        // 좌우 이동 제한: previewView 안에서만 이동 가능
        newCenter.x = max(previewFrame.minX + halfWidth, min(newCenter.x, previewFrame.maxX - halfWidth))
        
        // 상하 이동 제한: previewView의 상단과 recordButton의 상단 사이에서만 이동 가능
        let recordButtonTopY = recordingView.recordButton.frame.minY
        let lowerBound = recordButtonTopY - 10 - halfHeight
        let upperBound = previewFrame.minY + halfHeight
        newCenter.y = max(upperBound, min(newCenter.y, lowerBound))
        
        // 새로운 위치 적용
        scriptTextView.center = newCenter
        
        // 현재 변화를 기준으로 translation 초기화
        gesture.setTranslation(.zero, in: view)
        
        // 드래그 후 위치 고정 (Auto Layout 업데이트)
        if gesture.state == .ended {
            updateScriptTextViewConstraints(for: scriptTextView.center)
        }
    }
    
    func updateScriptTextViewConstraints(for center: CGPoint) {
        // 새로운 위치에 따른 오토레이아웃 제약 조건을 재설정하거나, Auto Layout을 비활성화 상태로 유지
        NSLayoutConstraint.deactivate(recordingView.scriptTextView.constraints) // 기존 제약 조건 비활성화
        
        // 새 위치로 제약 조건 설정 (Auto Layout 비활성화 유지)
        recordingView.scriptTextView.translatesAutoresizingMaskIntoConstraints = true
        recordingView.scriptTextView.center = center
    }
    
    @IBAction func bluetoothButtonTapped(_ sender: UIButton) {
        showOverlayView()
        BluetoothManager.shared.initializeCentralManager()
    }
    
    @objc func didConnectToPeripheral() {
        if BluetoothManager.shared.isConnected {
            if let originalImage = UIImage(named: "bluetooth") {
                let resizedImage = originalImage.resize(to: CGSize(width: 25, height: 25)) // 원하는 크기로 이미지 변경
                recordingView.bluetoothButton.setImage(resizedImage, for: .normal)
                recordingView.bluetoothButton.imageView?.contentMode = .center
            }
        } else {
            if let originalImage = UIImage(named: "bluetoothNot") {
                let resizedImage = originalImage.resize(to: CGSize(width: 25, height: 25)) // 원하는 크기로 이미지 변경
                recordingView.bluetoothButton.setImage(resizedImage, for: .normal)
                recordingView.bluetoothButton.imageView?.contentMode = .center
            }

        }
        
        dismissOverlayView()
    }
    
    func showOverlayView() {
        // 오버레이 뷰 생성 및 설정
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = CGPoint(x: overlayView.center.x, y: overlayView.center.y - 50)
        activityIndicator.startAnimating()
        
        let label = UILabel(frame: CGRect(x: 0, y: overlayView.center.y + 20, width: overlayView.bounds.width, height: 50))
        label.text = "주변 기기를 찾고 있습니다..."
        label.textColor = .white
        label.textAlignment = .center
        
        // UITableView 설정
        deviceTableView = UITableView(frame: CGRect(x: 0, y: overlayView.center.y + 80, width: overlayView.bounds.width, height: overlayView.bounds.height / 2))
        
        deviceTableView.delegate = self
        deviceTableView.dataSource = self
        deviceTableView.register(UINib(nibName: "CentralTableViewCell", bundle: nil), forCellReuseIdentifier: "CentralTableViewCell")
        
        // 취소 버튼 추가
        let cancelButton = UIButton(frame: CGRect(x: 0, y: 60, width: 60, height: 30))
            cancelButton.setTitle("취소", for: .normal)
            cancelButton.setTitleColor(.black, for: .normal)
            cancelButton.backgroundColor = UIColor.white
            cancelButton.layer.cornerRadius = 5
            cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        overlayView.addSubview(activityIndicator)
        overlayView.addSubview(label)
        overlayView.addSubview(deviceTableView)
        overlayView.addSubview(cancelButton)
        
        view.addSubview(overlayView)
    }
    
    func dismissOverlayView() {
        if overlayView.superview != nil {
            overlayView.removeFromSuperview()
        }
    }
    
    @objc func cancelButtonTapped() {
        // 오버레이 뷰 제거
        overlayView.removeFromSuperview()
    }
    
    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BluetoothManager.shared.discoveredDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CentralTableViewCell", for: indexPath) as! CentralTableViewCell
        
        let device = BluetoothManager.shared.discoveredDevices[indexPath.row]
        if BluetoothManager.shared.isConnected {
            cell.deviceName.text = device.peripheral.name ?? "unknown"
            cell.connectedLabel.isHidden = false
        } else {
            cell.deviceName.text = device.peripheral.name ?? "unknown"
            cell.connectedLabel.isHidden = true
        }
 
        
        return cell
    }
    
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeripheral = BluetoothManager.shared.discoveredDevices[indexPath.row].peripheral
        
        BluetoothManager.shared.connectToPeripheral(selectedPeripheral)
        
        //dismissOverlayView() // 기기를 선택한 후 오버레이 뷰 제거
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    
    //MARK: - Zoom Slider
    
    
    @objc func handleZoomChange(_ notification: Notification) {
        guard let zoomValue = notification.userInfo?["zoomValue"] as? CGFloat else { return }
        applyZoom(zoomValue: zoomValue)
    }
    
    func applyZoom(zoomValue: CGFloat) {
        guard let device = getCamera(for: currentCameraPosition) else { return }

        do {
            try device.lockForConfiguration()
            let zoomFactor = min(max(zoomValue, 1.0), device.activeFormat.videoMaxZoomFactor)
            device.videoZoomFactor = zoomFactor
            device.unlockForConfiguration()
        } catch {
            print("Error locking configuration: \(error.localizedDescription)")
        }
    }
    
    func setupZoomSlider() {
        // 슬라이더 생성
        zoomSlider = UISlider()
        
        // 슬라이더의 최소값과 최대값 설정
        zoomSlider.minimumValue = 1.0
        zoomSlider.maximumValue = 10.0
        
        // 초기 줌 비율 설정
        zoomSlider.value = 1.0
        
        // 슬라이더를 가로 방향으로 설정
        zoomSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(zoomSlider)
        
        // 슬라이더를 PreviewView의 하단에 배치
        NSLayoutConstraint.activate([
            zoomSlider.leadingAnchor.constraint(equalTo: recordingView.previewView.leadingAnchor, constant: 40),
            zoomSlider.trailingAnchor.constraint(equalTo: recordingView.previewView.trailingAnchor, constant: -40),
            zoomSlider.bottomAnchor.constraint(equalTo: recordingView.previewView.bottomAnchor, constant: -20)
        ])
        
        // thumb 크기를 줄이기 위해 새로운 thumb 이미지 설정
        let thumbSize = CGSize(width: 15, height: 15)
        UIGraphicsBeginImageContextWithOptions(thumbSize, false, 0.0)
        UIColor.white.setFill() // 원하는 색상으로 변경
        UIBezierPath(ovalIn: CGRect(origin: .zero, size: thumbSize)).fill()
        let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        zoomSlider.setThumbImage(thumbImage, for: .normal)
        
        // 트랙 색상 설정
        zoomSlider.minimumTrackTintColor = UIColor.white // 최소값 트랙 색상 변경
        zoomSlider.maximumTrackTintColor = UIColor.gray // 최대값 트랙 색상 변경
        
        // 슬라이더를 초기에는 숨김 상태로 설정
        zoomSlider.alpha = 0.0
        
        // 슬라이더 값 변경 시 실행될 메서드 설정
        zoomSlider.addTarget(self, action: #selector(zoomSliderChanged(_:)), for: .valueChanged)
        
        // '-' 기호 레이블 추가
        minusLabel = UILabel()
        minusLabel.text = "−" // Unicode 마이너스 기호 사용
        minusLabel.textColor = .white
        minusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(minusLabel)
        
        NSLayoutConstraint.activate([
            minusLabel.centerYAnchor.constraint(equalTo: zoomSlider.centerYAnchor),
            minusLabel.trailingAnchor.constraint(equalTo: zoomSlider.leadingAnchor, constant: -10)
        ])
        
        // '+' 기호 레이블 추가
        plusLabel = UILabel()
        plusLabel.text = "+"
        plusLabel.textColor = .white
        plusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusLabel)
        
        NSLayoutConstraint.activate([
            plusLabel.centerYAnchor.constraint(equalTo: zoomSlider.centerYAnchor),
            plusLabel.leadingAnchor.constraint(equalTo: zoomSlider.trailingAnchor, constant: 10)
        ])
        
        // 레이블도 초기에는 숨김 상태로 설정
        minusLabel.alpha = 0.0
        plusLabel.alpha = 0.0
    }
    
    @objc func zoomSliderChanged(_ sender: UISlider) {
        guard let device = getCamera(for: currentCameraPosition) else { return }
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = CGFloat(sender.value)
            device.unlockForConfiguration()
        } catch {
            print("Error locking configuration: \(error.localizedDescription)")
        }
        
        showZoomControls()
    }
    
    func showZoomControls() {
        // 슬라이더와 레이블을 표시
        UIView.animate(withDuration: 0.2) {
            self.zoomSlider.alpha = 1.0
            self.minusLabel.alpha = 1.0
            self.plusLabel.alpha = 1.0
        }
        
        // 일정 시간 후에 사라지도록 설정
        UIView.animate(withDuration: 0.2, delay: 1.5, options: [], animations: {
            self.zoomSlider.alpha = 0.0
            self.minusLabel.alpha = 0.0
            self.plusLabel.alpha = 0.0
        }, completion: nil)
    }
    
    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let device = getCamera(for: currentCameraPosition) else { return }
        
        if gesture.state == .began {
            showZoomSlider()
        }
        
        if gesture.state == .changed {
            do {
                try device.lockForConfiguration()
                
                // 현재 줌 팩터를 기반으로 줌인/줌아웃 계산
                let zoomFactor = min(max(device.videoZoomFactor * gesture.scale, 1.0), device.activeFormat.videoMaxZoomFactor)
                device.videoZoomFactor = zoomFactor
                
                // 슬라이더 값 업데이트
                zoomSlider.value = Float(zoomFactor)
                
                gesture.scale = 1.0 // 다음 변화를 위해 scale을 초기화
                
                device.unlockForConfiguration()
            } catch {
                print("Error locking configuration: \(error.localizedDescription)")
            }
        }
        
        if gesture.state == .ended {
            startHideSliderTimer()
        }
    }
    
    
    func showZoomSlider() {
        // 슬라이더와 레이블을 표시
        UIView.animate(withDuration: 0.3) {
            self.zoomSlider.alpha = 1.0
            self.minusLabel.alpha = 1.0
            self.plusLabel.alpha = 1.0
        }
        // 기존 타이머가 있으면 무효화
        hideSliderTimer?.invalidate()
    }
    
    func startHideSliderTimer() {
        // 일정 시간 후 슬라이더와 레이블 숨김
        hideSliderTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            UIView.animate(withDuration: 0.3) {
                self.zoomSlider.alpha = 0.0
                self.minusLabel.alpha = 0.0
                self.plusLabel.alpha = 0.0
            }
        }
    }
    
    @objc func handleZoomCommand(_ notification: Notification) {
        guard let zoomIn = notification.userInfo?["zoomIn"] as? Bool else { return }
        adjustZoom(zoomIn: zoomIn)
    }
    
    func adjustZoom(zoomIn: Bool) {
        guard let device = getCamera(for: currentCameraPosition) else { return }

        do {
            try device.lockForConfiguration()
            let currentZoom = device.videoZoomFactor
            let maxZoom = device.activeFormat.videoMaxZoomFactor
            let zoomFactor: CGFloat = 1.0

            if zoomIn {
                device.videoZoomFactor = min(currentZoom + zoomFactor, maxZoom)
            } else {
                device.videoZoomFactor = max(currentZoom - zoomFactor, 1.0)
            }

            device.unlockForConfiguration()
        } catch {
            print("Error locking configuration: \(error.localizedDescription)")
        }
    }
    
    //MARK: - Script Progress Bar
    
    // UIProgressView 설정
    private func setupProgressBar() {
        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.progressTintColor = UIColor.green // 진행된 부분의 색상
        progressBar.trackTintColor = UIColor.lightGray // 진행되지 않은 부분의 색상
        
        recordingView.addSubview(progressBar)
        
        // Auto Layout 제약 설정
        NSLayoutConstraint.activate([
            progressBar.leadingAnchor.constraint(equalTo: recordingView.scriptTextView.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: recordingView.scriptTextView.trailingAnchor),
            progressBar.topAnchor.constraint(equalTo: recordingView.scriptTextView.bottomAnchor, constant: 8), // scriptTextView 하단에 위치
            progressBar.heightAnchor.constraint(equalToConstant: 2) // 높이를 2포인트로 설정
        ])
        
        progressBar.isHidden = true
    }
    
    // 스크립트 스크롤과 함께 프로그레스 바 업데이트
    func updateProgressBar() {
        let contentHeight = recordingView.scriptTextView.contentSize.height
        let visibleHeight = recordingView.scriptTextView.frame.height
        let currentOffset = recordingView.scriptTextView.contentOffset.y
        
        // 프로그레스 계산
        let progress = Float(currentOffset / (contentHeight - visibleHeight))
        progressBar.setProgress(progress, animated: true)
    }
    
    
    //MARK: -  Camera Quality
    @objc func qualityButtonTapped() {
        isHD60Selected.toggle() // 현재 상태를 토글
        if isHD60Selected {
            configureSession(for: .hd60)
            recordingView.qualityButton.setTitle("HD 60", for: .normal)
        } else {
            configureSession(for: .hd30)
            recordingView.qualityButton.setTitle("HD 30", for: .normal)
        }
    }
    
    func configureSession(for quality: VideoQuality) {
        captureSession.beginConfiguration()
        
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        
        guard let camera = getCamera(for: currentCameraPosition) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            switch quality {
            case .hd30:
                setFormat(for: camera, with: 30, width: 1920, height: 1080)
            case .hd60:
                setFormat(for: camera, with: 60, width: 1920, height: 1080)
            }
            
        } catch {
            print("Error setting up camera input: \(error.localizedDescription)")
        }
        
        captureSession.commitConfiguration()
    }
    
    func setFormat(for device: AVCaptureDevice, with frameRate: Int, width: Int, height: Int) {
        var selectedFormat: AVCaptureDevice.Format?
        let formats = device.formats
        
        for format in formats {
            let formatDesc = format.formatDescription
            let dimensions = CMVideoFormatDescriptionGetDimensions(formatDesc)
            
            if dimensions.width == width && dimensions.height == height {
                let ranges = format.videoSupportedFrameRateRanges
                if let frameRateRange = ranges.first, frameRateRange.maxFrameRate >= Double(frameRate) {
                    selectedFormat = format
                    break
                }
            }
        }
        
        do {
            if let selectedFormat = selectedFormat {
                try device.lockForConfiguration()
                device.activeFormat = selectedFormat
                device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
                device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(frameRate))
                device.unlockForConfiguration()
            }
        } catch {
            print("Error setting device format: \(error.localizedDescription)")
        }
    }
    
    //MARK: - SettingView 관련
    
    @objc func handleFontSizeChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let fontSize = userInfo["fontSize"] as? CGFloat else { return }
        
        // scriptView의 폰트 크기 변경
        recordingView.scriptTextView.font = UIFont.systemFont(ofSize: fontSize)
        
        // 폰트 크기 변경 확인을 위한 디버그 로그 추가
        print("Updated scriptTextView font size to: \(fontSize)")
    }
    
    @objc func handleScrollOptionChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo, let option = userInfo["scrollOption"] as? Bool {
            isContinuousScrollEnabled = option
            print("Scroll option updated to: \(isContinuousScrollEnabled ? "Continuous" : "Segmented")")
            
            print("\(isContinuousScrollEnabled)--------------")
            
            // 스크롤 옵션 변경에 따라 즉시 스크립트 뷰를 업데이트
            if isContinuousScrollEnabled {
                // 모든 텍스트를 한 번에 표시
                showAllScriptText()
            } else {
                // 5줄씩 끊어서 표시
                resetScriptView()
                updateScriptView()
            }
        }
    }
    
    @objc func handleBackgroundAlphaChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo, let alphaValue = userInfo["alphaValue"] as? CGFloat {
            // 스크립트 배경색의 투명도 업데이트
            let backgroundColor = recordingView.scriptTextView.backgroundColor?.withAlphaComponent(alphaValue)
            recordingView.scriptTextView.backgroundColor = backgroundColor
            print("Background alpha updated to \(alphaValue)")
        }
    }
    
    @objc func handleScrollSpeedChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo, let speedValue = userInfo["scrollSpeed"] as? TimeInterval {
            scrollSpeed = speedValue
            print("Scroll speed updated to \(scrollSpeed) seconds")
        }
    }
    
    // UserDefaults에서 설정을 로드하는 메서드
    func loadSettings(completion: @escaping () -> Void) {
        let defaults = UserDefaults.standard
        isContinuousScrollEnabled = defaults.bool(forKey: "scrollOption")
        backgroundAlpha = CGFloat(defaults.float(forKey: "backgroundAlpha"))
        scrollSpeed = TimeInterval(defaults.float(forKey: "scrollSpeed"))
        fontSize = CGFloat(defaults.float(forKey: "fontSize"))
        
        // 로드된 값을 적용
        let backgroundColor = recordingView.scriptTextView.backgroundColor?.withAlphaComponent(backgroundAlpha)
        recordingView.scriptTextView.backgroundColor = backgroundColor
        
        print("Loaded settings: Scroll Option = \(isContinuousScrollEnabled), Background Alpha = \(backgroundAlpha), Scroll Speed = \(scrollSpeed) seconds, font = \(fontSize)")
        
        completion()
    }
    
    
    
    
    func getCamera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: position
        )
        
        return deviceDiscoverySession.devices.first { $0.position == position }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("Recording finished.")
        
        if let error = error {
            print("Error recording movie: \(error.localizedDescription)")
        } else {
            // SaveVideoViewController로 전환
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let saveVC = storyboard.instantiateViewController(withIdentifier: "SaveVideoViewController") as? SaveVideoViewController {
                let videoModel = VideoModel(videoURL: outputFileURL)
                saveVC.videoModel = videoModel
                saveVC.modalPresentationStyle = .fullScreen
                present(saveVC, animated: true, completion: nil)
            }
        }
    }
}
