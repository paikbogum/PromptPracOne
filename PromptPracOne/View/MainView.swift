//
//  MainView.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/27/24.
//

import UIKit
import GoogleMobileAds


class MainView: UIView {
    @IBOutlet weak var scriptTableView: UITableView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var bluetoothButton: UIButton!
    
    @IBOutlet weak var languageButton: UIButton!
    
    @IBOutlet weak var infoButton: UIButton!
    
    
    let demoAdmobView: GADBannerView = { // admob 부분
        var view = GADBannerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    func setTableViewUI() {
        mainLabel.font = UIFont.boldSystemFont(ofSize: 25)
        mainLabel.textColor = .white
        mainLabel.text = "전체 프로젝트"
        
        scriptTableView.backgroundColor = .clear
        bluetoothButton.tintColor = .white
        
        languageButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        languageButton.tintColor = .white
        languageButton.backgroundColor = .clear
        infoButton.tintColor = .white
        infoButton.backgroundColor = .clear
    }
}


