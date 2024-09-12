//
//  AddScriptTableViewCell.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/29/24.
//

import UIKit

class AddScriptTableViewCell: UITableViewCell {
    @IBOutlet weak var mainUIView: UIView!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setUI()
    }
    
    
    func setUI() {
        contentView.backgroundColor = .black
        //mainUIView.layer.borderColor = UIColor.black.cgColor
        //mainUIView.layer.borderWidth = 1.0
        mainUIView.backgroundColor = .black
        mainUIView.clipsToBounds = true
        addButton.tintColor = .white
        addButton.isUserInteractionEnabled = false
        addLabel.font = UIFont.boldSystemFont(ofSize: 15)
        addLabel.textColor = .white
        addLabel.text = "프로젝트 추가"
    }
    
}
