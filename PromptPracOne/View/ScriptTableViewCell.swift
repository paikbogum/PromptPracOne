//
//  ScriptTableViewCell.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/27/24.
//

protocol ScriptTableViewCellDelegate: AnyObject {
    func didTapScriptButton(at indexPath: IndexPath)
    func didTapRecordButton(at indexPath: IndexPath)
    func didTapTrashButton(at indexPath: IndexPath)
}

import UIKit

class ScriptTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainUIView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var scriptButton: UIButton!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var trashButton: UIButton!
    
    @IBOutlet weak var mainUIViewHeightConstraint: NSLayoutConstraint!
    
    var delegate: ScriptTableViewCellDelegate?
    var indexPath: IndexPath?
    
    var isExpanded: Bool = false {
        didSet {
            mainUIViewHeightConstraint.constant = isExpanded ? 105 : 50 // 예시로 200을 사용
            scriptButton.isHidden = isExpanded ? false : true
            recordButton.isHidden = isExpanded ? false : true
            trashButton.isHidden = isExpanded ? false : true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUI()
        
        scriptButton.addTarget(self, action: #selector(scriptButtonTapped), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        trashButton.addTarget(self, action: #selector(trashButtonTapped), for: .touchUpInside)
    }
    
    @objc func scriptButtonTapped() {
        if let indexPath = indexPath {
            delegate?.didTapScriptButton(at: indexPath)
        }
    }
    
    @objc func recordButtonTapped() {
        if let indexPath = indexPath {
            delegate?.didTapRecordButton(at: indexPath)
        }
    }
    
    @objc func trashButtonTapped() {
        if let indexPath = indexPath {
            delegate?.didTapTrashButton(at: indexPath)
        }
    }
    
    
    func setUI() {
        //contentView는 배경색이랑 일치 시켜야함
        contentView.backgroundColor = .black
        mainUIView.backgroundColor = .black
        mainUIView.clipsToBounds = true
        mainUIViewHeightConstraint.constant = 50
        //mainUIView.layer.cornerRadius = 4
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        
        scriptButton.tintColor = .white
        recordButton.tintColor = .white
        trashButton.tintColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
}
