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
    
    @IBOutlet weak var remainTimeLabel: UILabel!
    
    @IBOutlet weak var progressBar: UISlider!
    
    
    func setButtonUI() {
        
        currentTimeLabel.isHidden = true
        
        cancelButton.tintColor = .white
        downLoadButton.tintColor = .white
        playPauseButton.tintColor = .white
        currentTimeLabel.textColor = .white
        
        remainTimeLabel.textColor = .white
        remainTimeLabel.font = UIFont.boldSystemFont(ofSize: 12)
        
        customizeSliderThumb()
        
    }
    
    private func customizeSliderThumb() {
        // 기존 시스템 이미지를 크기 조정
        if let originalThumbImage = UIImage(systemName: "circle.fill") {
            let resizedThumbImage = resizeImage(image: originalThumbImage, targetSize: CGSize(width: 10, height: 10))
            progressBar.setThumbImage(resizedThumbImage, for: .normal)
            progressBar.setThumbImage(resizedThumbImage, for: .highlighted)
            progressBar.minimumTrackTintColor = .white
        }
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    
}
