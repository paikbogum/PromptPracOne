//
//  PeripheralView.swift
//  PromptPracOne
//
//  Created by 백현진 on 9/7/24.
//

import Foundation
import UIKit

class PeripheralView: UIView {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraSwitchButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    
    @IBOutlet weak var qualityButton: UIButton!
    
    @IBOutlet weak var mainUIView: UIView!
    
    @IBOutlet weak var scriptTextView: UITextView!
    
    func setButtonUI() {
        
        recordButton.backgroundColor = .red
        recordButton.clipsToBounds = true
        recordButton.layer.cornerRadius = recordButton.frame.size.width / 2
        recordButton.layer.borderWidth = 1.0
        recordButton.layer.borderColor = UIColor.white.cgColor
        
        cameraSwitchButton.tintColor = .white
        cameraSwitchButton.backgroundColor = .clear
        
        zoomInButton.tintColor = .white
        zoomInButton.backgroundColor = .clear
        
        zoomOutButton.tintColor = .white
        zoomOutButton.backgroundColor = .clear
        
        qualityButton.tintColor = .white
        qualityButton.backgroundColor = .clear
        
        mainUIView.backgroundColor = CustomColor.darkModeDarkGrayColor.color
        mainUIView.layer.cornerRadius = 8
        mainUIView.clipsToBounds = true
        
        statusLabel.font = UIFont.boldSystemFont(ofSize: 16)
        statusLabel.textColor = .lightGray
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.numberOfLines = 0  // 자동 줄바꿈을 위해 numberOfLines를 0으로 설정
        statusLabel.textAlignment = .center // 텍스트 가운데 정렬
        
        scriptTextView.backgroundColor = .black
        scriptTextView.layer.borderColor = CustomColor.darkModeDarkGrayColor.color.cgColor
        scriptTextView.layer.borderWidth = 2.0
        scriptTextView.layer.cornerRadius = 8
        scriptTextView.clipsToBounds = true
        scriptTextView.isEditable = false
        
        scriptTextView.textColor = .white
        scriptTextView.font = UIFont.systemFont(ofSize: 14)
        scriptTextView.textAlignment = .center
        
        
    }
}

