//
//  CustomColor.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/28/24.
//

import UIKit

enum CustomColor {
    case backgroundColor
    case caldendarFontColor
    case weakCalendarFontColor
    case kakaoYellowFontColor
    case strongCalendarColor
    case selectGreenColor
    case darkModeBackgroundColor
    case darkModeDarkGrayColor
    case upImportantColor
    case exBlack
    case exBlackIn
    case holidayRed
    
    var color: UIColor {
        switch self {
            // 회색 백그라운드
        case .backgroundColor:
            //return UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1.0)
            return UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0)
            
            // 보트 시그니처 컬러(파랑)
        case .caldendarFontColor:
            return UIColor(red: 97/255, green: 163/255, blue: 243/255, alpha: 1.0)
            
            // 연한 파랑
        case .weakCalendarFontColor:
            return UIColor(red: 227/255, green: 242/255, blue: 253/255, alpha: 1.0)
            
            //카카오 색상
        case .kakaoYellowFontColor:
            return UIColor(red: 254/255, green: 229/255, blue: 0/255, alpha: 1.0)
            
            //진한 파랑
        case .strongCalendarColor:
            return UIColor(red: 90/255, green: 170/255, blue: 255/255, alpha: 1.0)
            
            //초록색
        case .selectGreenColor:
            return UIColor(red: 0/255, green: 239/255, blue: 0/255, alpha: 1.0)
            
        case .darkModeBackgroundColor:
            return UIColor(red: 30/255, green: 31/255, blue: 34/255, alpha: 1.0)
            
        case .darkModeDarkGrayColor:
            return UIColor(red: 49/255, green: 51/255, blue: 56/255, alpha: 1.0)
            
        case .upImportantColor:
            return UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0)
            
            
        case .exBlack:
            return UIColor(red: 42/255, green: 43/255, blue: 45/255, alpha: 1.0)
            
        case .exBlackIn:
            return UIColor(red: 50/255, green: 51/255, blue: 55/255, alpha: 1.0)
            
        case .holidayRed:
            return UIColor(red: 227/255, green: 64/255, blue: 51/255, alpha: 1.0)
            
        }
    
    }
}
