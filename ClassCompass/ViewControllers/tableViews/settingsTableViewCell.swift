//
//  settingsTableViewCell.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/30/23.
//

import UIKit

class settingsTableViewCell: UITableViewCell, UITextFieldDelegate {

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
        // ToDo: Add code to save the setting in the database
        //       get id of data from label
        print(textField.text ?? "")
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
