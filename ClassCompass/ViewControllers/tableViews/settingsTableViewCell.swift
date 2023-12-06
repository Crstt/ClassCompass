//
//  settingsTableViewCell.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/30/23.
//

import UIKit

class settingsTableViewCell: UITableViewCell, UITextFieldDelegate {
    weak var delegate: SettingsTableViewCellDelegate?

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }
    
    func getText() -> String {
        return textField.text ?? ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        super.setSelected(false, animated: true)
        delegate?.textFieldDidEndEditing(in: self)
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        super.setSelected(true, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

protocol SettingsTableViewCellDelegate: AnyObject {
    func textFieldDidEndEditing(in cell: settingsTableViewCell)
}
