//
//  MainView.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/27/24.
//

import UIKit


class MainView: UIView {
    @IBOutlet weak var scriptTableView: UITableView!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var bluetoothButton: UIButton!
    
    func setTableViewUI() {
        mainLabel.font = UIFont.boldSystemFont(ofSize: 25)
        mainLabel.textColor = .white
        mainLabel.text = "전체 프로젝트"
        
        scriptTableView.backgroundColor = .clear
        bluetoothButton.tintColor = .white
    }
    
    
}
