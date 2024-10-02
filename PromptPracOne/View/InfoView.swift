//
//  InfoView.swift
//  PromptPracOne
//
//  Created by 백현진 on 10/1/24.
//

import UIKit

class InfoView: UIView {
    @IBOutlet weak var mainUIView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var privacyButton: UIButton!
    
    @IBOutlet weak var dismissButton: UIButton!
    
    let singletonMan = LanguageManager.shared
    
    func setUI() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        
        mainUIView.clipsToBounds = true
        mainUIView.layer.cornerRadius = 4
        mainUIView.backgroundColor = CustomColor.darkModeDarkGrayColor.color
        
        titleLabel.text = "PromptShot"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = .white
        titleLabel.backgroundColor = .clear
        
        emailLabel.text = singletonMan.setLanguageText(key: "emailLabel")
        emailLabel.font = UIFont.systemFont(ofSize: 15)
        emailLabel.textColor = .white
        emailLabel.backgroundColor = .clear
        
        versionLabel.text = "\(singletonMan.setLanguageText(key: "versionLabel"))\(appVersion)"
        versionLabel.font = UIFont.systemFont(ofSize: 15)
        versionLabel.backgroundColor = .clear
        versionLabel.textColor = .white
        

        privacyButton.setTitle(singletonMan.setLanguageText(key: "privacyBtn"), for: .normal)
        privacyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        privacyButton.backgroundColor = .clear
        
        dismissButton.tintColor = .white
    }
}
