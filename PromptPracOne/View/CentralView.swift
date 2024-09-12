//
//  CentralView.swift
//  PromptPracOne
//
//  Created by 백현진 on 9/7/24.
//

import Foundation
import UIKit

class CentralView: UIView {
    
    @IBOutlet weak var deviceTableView: UITableView!
    
    func setUI() {
        self.backgroundColor = .white
        deviceTableView.backgroundColor = .clear
    }
}
