//
//  AppDelegate.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/12/24.
//

import UIKit
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import SwiftRater

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //애드몹
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // 앱 추적 권한 요청
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:           // 허용됨
                        print("Authorized")
                        print("IDFA = \(ASIdentifierManager.shared().advertisingIdentifier)")
                    case .denied:               // 거부됨
                        print("Denied")
                    case .notDetermined:        // 결정되지 않음
                        print("Not Determined")
                    case .restricted:           // 제한됨
                        print("Restricted")
                    @unknown default:           // 알려지지 않음
                        print("Unknow")
                    }
                }
            }
        }
        
        // UserDefaults에 AppleLanguages 값이 있는지 확인(초기 설정을 위함)
         if UserDefaults.standard.array(forKey: "AppleLanguages") == nil {
             // AppleLanguages가 없다면 기기의 기본 언어를 저장
             if let deviceLanguage = Locale.preferredLanguages.first {
                 let languageCode = String(deviceLanguage.prefix(2)) // 언어 코드만 저장 (ko, en 등)
                 UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
                 UserDefaults.standard.synchronize()
                 print("기기의 언어가 저장되었습니다: \(languageCode)")
             }
         }
        
        //인앱 리뷰 라이브러리
        SwiftRater.daysUntilPrompt = 7 // 앱을 시작한 이후 5일이 지난 후에 리뷰 요청
        SwiftRater.usesUntilPrompt = 7 // 앱을 실행한 횟수가 5회 이상일 때 리뷰 요청
        SwiftRater.significantUsesUntilPrompt = 3 // 앱 사용자가 앱에서 새로운 기능을 사용한 횟수가 3회 이상일 때 리뷰 요청
        SwiftRater.daysBeforeReminding = 7 // 리뷰 요청을 거절한 이후 7일이 지나면 다시 리뷰 요청
        SwiftRater.showLaterButton = true // "나중에" 버튼을 보여줍니다.
        SwiftRater.debugMode = false // 테스트에 유용한 디버그 모드에서 프롬프트가 표시되는지 여부를 결정합니다.
        SwiftRater.appLaunched() // 앱이 시작되었음을 라이브러리에 알리는 데 사용됩니다.
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

