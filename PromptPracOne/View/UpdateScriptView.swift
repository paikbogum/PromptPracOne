//
//  UpdateScriptView.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/27/24.
//

import UIKit

class UpdateScriptView: UIView {
    
    @IBOutlet weak var mainUIView: UIView!
    
    @IBOutlet weak var titleTF: UITextField!
    
    @IBOutlet weak var scriptTv: UITextView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    let singletonMan = LanguageManager.shared
    
    func setMainUIViewUI() {
        mainUIView.layer.cornerRadius = 8
        mainUIView.clipsToBounds = true
        mainUIView.backgroundColor = CustomColor.darkModeBackgroundColor.color
        
        //submitButton.layer.cornerRadius = 8
        //submitButton.clipsToBounds = true
        submitButton.tintColor = .white
        submitButton.backgroundColor = .clear
        submitButton.setTitle(singletonMan.setLanguageText(key: "save"), for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)

        
        
        mainLabel.font = UIFont.boldSystemFont(ofSize: 22)
        mainLabel.textColor = .white
        mainLabel.text = singletonMan.setLanguageText(key: "addProject")
    }
    
    func setTextfieldUI() {
        titleTF.backgroundColor = .black
        titleTF.layer.cornerRadius = 8
        titleTF.clipsToBounds = true
        titleTF.placeholder = singletonMan.setLanguageText(key: "titlePlaceholder")
        titleTF.textColor = .white
        titleTF.font = UIFont.boldSystemFont(ofSize: 18)
    }
    
    func setTextViewUI() {
        scriptTv.backgroundColor = .black
        scriptTv.textColor = .white
        scriptTv.font = UIFont.systemFont(ofSize: 14)
        scriptTv.layer.cornerRadius = 8
        scriptTv.clipsToBounds = true
    }
}
