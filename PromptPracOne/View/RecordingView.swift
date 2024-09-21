//
//  RecordingView.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/22/24.
//

import UIKit

class RecordingView: UIView {
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var scriptTextView: UITextView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    
    @IBOutlet weak var bluetoothButton: UIButton!
    
    var countdownLabel: UILabel!

    @IBOutlet weak var qualityButton: UIButton!
    
    func setCameraQuality() {
        qualityButton.tintColor = .white
        qualityButton.backgroundColor = .clear
        qualityButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        qualityButton.setTitle("HD 30", for: .normal)
    }
    
    func setupCountdownLabel() {
        countdownLabel = UILabel(frame: bounds)
        countdownLabel.font = UIFont.systemFont(ofSize: 100, weight: .bold)
        countdownLabel.textColor = .white
        countdownLabel.textAlignment = .center
        countdownLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        countdownLabel.isHidden = true
        addSubview(countdownLabel)
    }
    
    func setInitialButtonUI() {
        recordButton.backgroundColor = .red
        recordButton.clipsToBounds = true
        recordButton.layer.cornerRadius = recordButton.frame.size.width / 2
        recordButton.layer.borderWidth = 1.0
        recordButton.layer.borderColor = UIColor.white.cgColor
        
        if let originalImage = UIImage(named: "bluetoothNot") {
            let resizedImage = originalImage.resize(to: CGSize(width: 25, height: 25)) // 원하는 크기로 이미지 변경
            bluetoothButton.setImage(resizedImage, for: .normal)
            bluetoothButton.imageView?.contentMode = .center
            }
       }
    
    func setStopButtonUI() {
        let largeConfig = UIImage.SymbolConfiguration(scale: .large)
        let largeImage = UIImage(systemName: "stop.fill")?.withConfiguration(largeConfig)
        
        
        recordButton.backgroundColor = .clear
        recordButton.clipsToBounds = true
        recordButton.layer.cornerRadius = recordButton.frame.size.width / 2
        recordButton.layer.borderWidth = 1.0
        recordButton.layer.borderColor = UIColor.white.cgColor
        recordButton.setImage(largeImage, for: .normal)
        recordButton.tintColor = .red
    
    }
    
    
    func setScriptViewUI() {
        scriptTextView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        scriptTextView.layer.cornerRadius = 8
        scriptTextView.clipsToBounds = true
        
        switchCameraButton.tintColor = .white
        settingButton.tintColor = .white
    }
    
    func updateScriptView(with text: String) {
        scriptTextView.text = text
        scriptTextView.textAlignment = .center
        scriptTextView.setContentOffset(.zero, animated: false)
    }
    
    func updateRecordingTimeLabel(with time: String) {
        recordingTimeLabel.text = time
    }
}
