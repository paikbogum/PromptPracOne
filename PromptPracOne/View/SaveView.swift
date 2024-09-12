//
//  SaveView.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/31/24.
//

import Foundation
import UIKit


class SaveView: UIView {
    
    @IBOutlet weak var videoContainerView: UIView!

    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var downLoadButton: UIButton!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    func setButtonUI() {
        
        currentTimeLabel.isHidden = true
        
        cancelButton.tintColor = .white
        downLoadButton.tintColor = .white
        playPauseButton.tintColor = .white
        currentTimeLabel.textColor = .white
    }
}
