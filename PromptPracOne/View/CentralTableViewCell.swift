//
//  CentralTableViewCell.swift
//  PromptPracOne
//
//  Created by 백현진 on 9/7/24.
//

import UIKit

class CentralTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setCellUI()
    }
    
    func setCellUI() {
        deviceName.textColor = .white
        contentView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
