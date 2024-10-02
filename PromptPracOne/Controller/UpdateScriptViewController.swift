//
//  UpdateScriptViewController.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/27/24.
//

import UIKit

class UpdateScriptViewController: UIViewController {
    @IBOutlet var updateScriptView: UpdateScriptView!
    
    var dismissTapGesture: UITapGestureRecognizer?
    var tapGesture: UITapGestureRecognizer?
    let singletonMan = LanguageManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        setupKeyboardDismissGesture()
    }

    func setUI() {
        //updateScriptView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        updateScriptView.backgroundColor = CustomColor.darkModeBackgroundColor.color
        updateScriptView.setTextfieldUI()
        updateScriptView.setTextViewUI()
        updateScriptView.setMainUIViewUI()
    }

    func setupKeyboardDismissGesture() {
        // 키보드를 닫기 위한 제스처
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture?.cancelsTouchesInView = false
        if let tapGesture = tapGesture {
            view.addGestureRecognizer(tapGesture)
        }
    }
    
    // 키보드를 닫는 메서드
    @objc func dismissKeyboard() {
        view.endEditing(true) // 현재 뷰에서 키보드를 닫음
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard let title = updateScriptView.titleTF.text, !title.isEmpty,
              let script = updateScriptView.scriptTv.text, !script.isEmpty else {
            showAlert(message: singletonMan.setLanguageText(key: "alertTitleAndScript"))
            return
        }
        
        // 기존 스크립트를 불러오기
        var scripts = UserDefaults.standard.dictionary(forKey: "scripts") as? [String: [String: Any]] ?? [:]
        
        // 현재 날짜를 추가하여 스크립트 저장
        let currentDate = Date()
        scripts[title] = ["script": script, "date": currentDate]
        
        // UserDefaults에 저장
        UserDefaults.standard.set(scripts, forKey: "scripts")
        
        // 스크립트가 추가된 후 NotificationCenter에 알림을 전송
        NotificationCenter.default.post(name: .didAddScript, object: nil)
         
         // 텍스트 필드와 텍스트 뷰 초기화
        updateScriptView.titleTF.text = ""
        updateScriptView.scriptTv.text = ""
        
        self.dismiss(animated: false)
        
    }
    
    // 알림을 표시하는 함수
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: singletonMan.setLanguageText(key: "check"), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
