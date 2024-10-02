//
//  SettingView.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/25/24.
//

import Foundation
import UIKit

class SettingView: UIView {
    @IBOutlet weak var scrollOptionSwitch: UISwitch!
    @IBOutlet weak var switchLabel: UILabel!
    
    @IBOutlet weak var fontView: UIView!
    
    @IBOutlet weak var scriptVolumeSlider: UISlider!
 
    @IBOutlet weak var sliderLabel: UILabel!
    
    @IBOutlet weak var speedView: UIView!
    
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var speedSlider: UISlider!
    
    @IBOutlet weak var alphaView: UIView!
    
    @IBOutlet weak var alphaLabel: UILabel!
    
    @IBOutlet weak var alphaSlider: UISlider!
    
    
    @IBOutlet weak var topSmallView: UILabel!
    
    let singletonMan = LanguageManager.shared
    
    
    func setFontViewUI() {
        switchLabel.text = singletonMan.setLanguageText(key: "switchLabel")
        switchLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        switchLabel.textColor = .white
        
        sliderLabel.text = singletonMan.setLanguageText(key: "sliderLabel")
        sliderLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        sliderLabel.textColor = .white
        
        fontView.clipsToBounds = true
        fontView.layer.cornerRadius = 10
        fontView.backgroundColor = .darkGray
        
        topSmallView.clipsToBounds = true
        topSmallView.layer.cornerRadius = 4
        topSmallView.backgroundColor = .lightGray
    }
    
    func setSpeedViewUI() {
        speedLabel.text = singletonMan.setLanguageText(key: "speedLabel")
        speedLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        speedLabel.textColor = .white
        
        speedView.clipsToBounds = true
        speedView.layer.cornerRadius = 10
        speedView.backgroundColor = .darkGray
    }
    
    
    func setAlphaViewUI() {
        alphaLabel.text = singletonMan.setLanguageText(key: "scriptAlpha")
        alphaLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .bold)
        alphaLabel.textColor = .white
        
        alphaView.clipsToBounds = true
        alphaView.layer.cornerRadius = 10
        alphaView.backgroundColor = .darkGray
    }
    
    
    
    
    
}
