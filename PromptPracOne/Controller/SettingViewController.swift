//
//  SettingViewController.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/24/24.
//

import UIKit

class SettingViewController: UIViewController {
    @IBOutlet var settingView: SettingView!
    
    var settingModel = SettingModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        sliderInit()
        loadSettings()
        
        // 초기 선택된 세그먼트 인덱스를 알림으로 전송
        sendScrollOption()
        sendBackgroundAlpha()
        sendScrollSpeed()
        sendFontSize()
        
        
        // UIPanGestureRecognizer 추가
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)

    }
    
    func setupUI() {
        settingView.setFontViewUI()
        settingView.setSpeedViewUI()
        settingView.setAlphaViewUI()
    }
    
    func sliderInit() {
        //폰트 크기 슬라이더 초기 값 설정
        settingView.scriptVolumeSlider.minimumValue = 10.0
        settingView.scriptVolumeSlider.maximumValue = 30.0
        //settingView.scriptVolumeSlider.value = 17.0
        
        //알파 슬라이더 초기 값 설정
        settingView.alphaSlider.minimumValue = 0.2
        settingView.alphaSlider.maximumValue = 1.0
        //settingView.alphaSlider.value = 0.7
        
        //스크롤 속도 슬라이더 초기값 설정
        settingView.speedSlider.minimumValue = 2.0
        settingView.speedSlider.maximumValue = 12.0
        
        //settingView.speedSlider.value = 6.0
    }
    
    func switchInit() {
        settingView.scrollOptionSwitch.isOn = false
    }
    
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        // 아래로 스와이프한 경우에만 처리
        if translation.y > 0 {
            view.transform = CGAffineTransform(translationX: 0, y: translation.y)
        }
        
        // 제스처가 종료된 경우
        if gesture.state == .ended {
            if translation.y > 150 {
                // 일정 거리 이상 스와이프 시 dismiss
                dismiss(animated: true, completion: nil)
            } else {
                // 스와이프가 일정 거리 미만이면 원래 위치로 돌아감
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = .identity
                }
            }
        }
    }
    
    //폰트 크기
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let newVal = round(sender.value)
        sender.value = newVal
        sendFontSize()
        settingView.sliderLabel.text = "폰트 크기(\(Int(newVal)))"
        saveSettings()
    }
    

    @IBAction func alphaSliderValueChanged(_ sender: UISlider) {
        // 0.1 단위로 값을 설정
        let newVal = round(sender.value * 10) / 10
        sender.value = newVal
        sendBackgroundAlpha()
        settingView.alphaLabel.text = "스크립트 투명도(\(newVal))"
        saveSettings()
    }
    
    @IBAction func speedSliderValueChanged(_ sender: UISlider) {
        // 스크롤 속도 값 변경
        let newVal = round(sender.value)
        sender.value = newVal
        sendScrollSpeed()
        settingView.speedLabel.text = "스크립트 속도(\(newVal)초)"
        saveSettings()
    }
    
    //자연스러운 스크롤
    @IBAction func switchValueChanged(_ sender: Any) {
        sendScrollOption()
        saveSettings()
    }
    
    func sendFontSize() {
        let fontSize = CGFloat(settingView.scriptVolumeSlider.value)
        NotificationCenter.default.post(name: .scriptViewFontSizeChanged, object: nil, userInfo: ["fontSize": fontSize])
    }
    
    func sendScrollOption() {
        let isOn = settingView.scrollOptionSwitch.isOn
        NotificationCenter.default.post(name: .scrollOptionChanged, object: nil, userInfo: ["scrollOption": isOn])
    }
    
    func sendBackgroundAlpha() {
        let alphaValue = CGFloat(settingView.alphaSlider.value)
        NotificationCenter.default.post(name: .backgroundAlphaChanged, object: nil, userInfo: ["alphaValue": alphaValue])
    }
    
    func sendScrollSpeed() {
        let speedValue = TimeInterval(settingView.speedSlider.value)
        NotificationCenter.default.post(name: .scrollSpeedChanged, object: nil, userInfo: ["scrollSpeed": speedValue])
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(settingView.scrollOptionSwitch.isOn, forKey: "scrollOption")
        defaults.set(settingView.alphaSlider.value, forKey: "backgroundAlpha")
        defaults.set(settingView.speedSlider.value, forKey: "scrollSpeed")
        defaults.set(settingView.scriptVolumeSlider.value, forKey: "fontSize")
    }
    
    func loadSettings() {
        let defaults = UserDefaults.standard
        
        // Scroll Option: 기본값은 false (끊어서 스크롤)
        if defaults.object(forKey: "scrollOption") != nil {
            settingView.scrollOptionSwitch.isOn = defaults.bool(forKey: "scrollOption")
        } else {
            settingView.scrollOptionSwitch.isOn = false // 기본값
        }
        
        // Background Alpha: 기본값은 1.0 (불투명)
        if defaults.object(forKey: "backgroundAlpha") != nil {
            settingView.alphaSlider.value = defaults.float(forKey: "backgroundAlpha")
            settingView.alphaLabel.text = "스크립트 투명도(\(defaults.float(forKey: "backgroundAlpha")))"
        } else {
            settingView.alphaSlider.value = 0.7 // 기본값
        }
        
        // Scroll Speed: 기본값은 6.0 초
        if defaults.object(forKey: "scrollSpeed") != nil {
            settingView.speedSlider.value = defaults.float(forKey: "scrollSpeed")
            settingView.speedLabel.text = "스크립트 속도(\(defaults.float(forKey: "scrollSpeed"))초)"
        } else {
            settingView.speedSlider.value = 6.0 // 기본값
        }
        
        // Font Size: 기본값은 17.0 (일반 텍스트 크기)
        if defaults.object(forKey: "fontSize") != nil {
            settingView.scriptVolumeSlider.value = defaults.float(forKey: "fontSize")
            settingView.sliderLabel.text = "폰트 크기(\(Int(defaults.float(forKey: "fontSize"))))"
        } else {
            settingView.scriptVolumeSlider.value = 17.0 // 기본값
        }
    }
    
}
