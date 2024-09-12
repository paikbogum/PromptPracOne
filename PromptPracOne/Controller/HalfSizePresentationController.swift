//
//  HalfSizePresentationController.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/25/24.
//

import Foundation
import UIKit

class HalfSizePresentationController: UIPresentationController {
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        
        let heightMultiplier: CGFloat = 0.6 // 높이를 0.6배로 설정
        let width = containerView.bounds.width
        let height = containerView.bounds.height * heightMultiplier
        let x = CGFloat(0)
        let y = containerView.bounds.height - height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func presentationTransitionWillBegin() {
        guard let presentedView = presentedView else { return }
        
        presentedView.layer.cornerRadius = 16
        presentedView.clipsToBounds = true
    }
}

class HalfSizeTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}
