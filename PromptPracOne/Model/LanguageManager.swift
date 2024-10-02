//
//  LanguageManager.swift
//  PromptPracOne
//
//  Created by 백현진 on 9/30/24.
//

import Foundation
import UIKit

class LanguageManager {
    static let shared = LanguageManager() // 싱글톤 인스턴스
    
    private init() {} // 외부에서 직접 인스턴스 생성 방지
    
    func setLanguage(for label: UILabel, key: String) {
        var language = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String
        if language == nil {
            let str = String(NSLocale.preferredLanguages[0])    // 언어코드-지역코드 (ex. ko-KR, en-US)
            language = String(str.dropLast(3))                  // ko-KR => ko, en-US => en
        }
        // 해당 언어 파일 가져오기
        let path = Bundle.main.path(forResource: language, ofType: "lproj") ?? Bundle.main.path(forResource: "en", ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        // 특정 키로 번역된 값을 가져옴
        label.text = bundle?.localizedString(forKey: key, value: nil, table: nil)
    }
    
    func setLanguageText(key: String) -> String {
        var language = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String
        if language == nil {
            let str = String(NSLocale.preferredLanguages[0])    // 언어코드-지역코드 (ex. ko-KR, en-US)
            language = String(str.dropLast(3))                  // ko-KR => ko, en-US => en
        }
        // 해당 언어 파일 가져오기
        let path = Bundle.main.path(forResource: language, ofType: "lproj") ?? Bundle.main.path(forResource: "en", ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        // 특정 키로 번역된 값을 가져옴
        return bundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
    
    
    
    func localizedString(forKey key: String) -> String {
        var language = UserDefaults.standard.string(forKey: "AppleLanguages")
        if language == nil {
            let str = String(NSLocale.preferredLanguages[0])
            language = String(str.dropLast(3))
        }
        
        let path = Bundle.main.path(forResource: language, ofType: "lproj") ?? Bundle.main.path(forResource: "en", ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return bundle?.localizedString(forKey: key, value: nil, table: nil) ?? key
    }
}


extension String {
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
}

