//
//  InfoViewController.swift
//  PromptPracOne
//
//  Created by 백현진 on 10/2/24.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet var infoView: InfoView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoView.setUI()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func privacyButtonTapped(_ sender: UIButton) {
        if let url = URL(string: "https://paikstorage.tistory.com/12") {
            UIApplication.shared.open(url)
        }
    }
    
    
    
    
}
