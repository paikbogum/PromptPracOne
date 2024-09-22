//
//  CentralTableViewCell.swift
//  PromptPracOne
//
//  Created by 백현진 on 9/7/24.
//

import UIKit

class CentralTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceName: UILabel!
    
    @IBOutlet weak var connectedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setCellUI()
    }
    
    func setCellUI() {
        deviceName.textColor = .white
        deviceName.font = UIFont.boldSystemFont(ofSize: 17)
        contentView.backgroundColor = .clear
        connectedLabel.textColor = .lightGray
        connectedLabel.font = UIFont.systemFont(ofSize: 12)
        connectedLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
