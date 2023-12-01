//
//  SettingsViewController.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/30/23.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "settingsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "settingsTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

var settings = [
    "Username",
    "Password",
    "API Token"
    ]

extension SettingsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? settingsTableViewCell {
            print(cell.label.text ?? "")
            print(cell.getText())
        }
    }
}

extension SettingsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsTableViewCell", for: indexPath) as! settingsTableViewCell
        
        cell.label?.text = settings[indexPath.row]
        
        return cell
    }
}
