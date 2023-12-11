//
//  agendaTableViewCell.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 12/7/23.
//

import UIKit

class agendaTableViewCell: UITableViewCell {
    
    var checkButton: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var assignmentLabel: UILabel!
    @IBOutlet weak var daysTillDue: UILabel!
    
    @IBAction func checkButton(_ sender: Any) {
        checkButton?()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
