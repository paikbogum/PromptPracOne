//
//  NotificationCenter.swift
//  PromptPracOne
//
//  Created by 백현진 on 9/13/24.
//

import Foundation

extension Notification.Name {
    //메인뷰
    static let didAddScript = Notification.Name("didAddScript")
    
    static let scriptViewFontSizeChanged = Notification.Name("scriptViewFontSizeChanged")
    
    static let scrollOptionChanged = Notification.Name("scrollOptionChanged")
    
    static let backgroundAlphaChanged = Notification.Name("backgroundAlphaChanged")
    
    static let scrollSpeedChanged = Notification.Name("scrollSpeedChanged")
    
    //블루투스 관련
    static let didConnectToPeripheral = Notification.Name("didConnectToPeripheral")
    static let didDisconnectFromPeripheral = Notification.Name("didDisconnectFromPeripheral")
    static let toggleRecording = Notification.Name("toggleRecording")
    static let didDiscoverPeripheral = Notification.Name("didDiscoverperipheral")
    static let toggleCamera = Notification.Name("toggleCamera")
}
