//
//  SettingsViewController.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/30/23.
//

import UIKit
import Foundation
import CommonCrypto

class SettingsViewController: UIViewController {
    
    var db: Database!
    var settings = [
        "API Token",
        "First Name",
        "Last Name",
        "Email",
        "Password"
        ]
    var settingsValues = [String: String]()
    var settingsDidChange: (([String: String]) -> Void)?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for setting in settings {
            if !settingsValues.contains(where: { $0.key == setting }) {
                settingsValues[setting] = ""
            }
        }
        
        if settingsValues["Password"] != "" && settingsValues["API Token"] != ""{
            guard let decryptPassword = SettingsViewController.decrypt(
                encryptedPassword: settingsValues["Password"]!,
                keyString: settingsValues["API Token"]!)else {
                
                print("Password decryption failed")
                return
            }
            //print(decryptPassword)
            settingsValues["Password"] = decryptPassword
        }
        
        
        let nib = UINib(nibName: "settingsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "settingsTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    static func saveSettingToPlist(key: String, value: Any) {
        // Get the file URL for the Settings.plist file
        if let plistURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Settings.plist") {
            // Check if the plist file exists
            if FileManager.default.fileExists(atPath: plistURL.path) {
                // If the file exists, load its contents into a mutable dictionary
                if let settingsDict = NSMutableDictionary(contentsOf: plistURL) {
                    // Update the value for the specified key
                    settingsDict[key] = value
                    
                    // Write the updated dictionary to the plist file
                    if settingsDict.write(to: plistURL, atomically: true) {
                        print("Setting saved successfully")
                    } else {
                        print("Error saving setting")
                    }
                }
            } else {
                // If the file doesn't exist, create a new dictionary and add the key-value pair
                let settingsDict: [String: Any] = [key: value]
                
                // Write the new dictionary to the plist file
                if (settingsDict as NSDictionary).write(to: plistURL, atomically: true) {
                    print("Setting saved successfully")
                } else {
                    print("Error saving setting")
                }
            }
        }
    }
    
    static func loadSettingsFromPlist() -> [String: String]? {
        // Get the file URL for the Settings.plist file
        if let plistURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Settings.plist") {
            // Check if the plist file exists
            if FileManager.default.fileExists(atPath: plistURL.path) {
                // Load contents from the plist file into a dictionary
                if let settingsDict = NSDictionary(contentsOf: plistURL) as? [String: String] {
                    return settingsDict
                }
            }
        }
        return nil
    }
    
    static func loadSettingByKey(key: String) -> String? {
        
        if let settingsDict = SettingsViewController.loadSettingsFromPlist() {
            if let value = settingsDict[key] {
                return value // Return value for the specified key
            } else {
                print("Key '\(key)' does not exist in the settings")
            }
        }else{
            print("Error loading settings")
        }
        return nil
    }


    static func generateRandomIV() -> Data {
        var randomIV = [UInt8](repeating: 0, count: kCCBlockSizeAES128)
        let result = SecRandomCopyBytes(kSecRandomDefault, randomIV.count, &randomIV)
        assert(result == errSecSuccess, "Failed to generate random bytes")
        return Data(randomIV)
    }
    
    static func encrypt(password: String, keyString: String) -> String? {
        // Convert the password string to Data
        guard let passwordData = password.data(using: .utf8) else { return nil }
        
        // Define key and initialization vector (IV)
        let keyString = keyString
        let ivData = generateRandomIV()
        
        SettingsViewController.saveSettingToPlist(key: "ivKey", value: ivData.base64EncodedString())
        
        // Convert key and IV strings to Data
        guard var keyData = keyString.data(using: .utf8) else { return nil }
        keyData.count = kCCKeySizeAES128
        
        // Prepare buffers
        var encryptedData = Data(count: passwordData.count + kCCBlockSizeAES128)
        var encryptedLength: Int = 0
        
        // Perform encryption
        let result = passwordData.withUnsafeBytes { passwordBytes in
            return ivData.withUnsafeBytes { ivBytes in
                return keyData.withUnsafeBytes { keyBytes in
                    return CCCrypt(
                        UInt32(kCCEncrypt), // Encrypt operation
                        UInt32(kCCAlgorithmAES), // AES algorithm
                        UInt32(kCCOptionPKCS7Padding), // Padding
                        keyBytes.baseAddress, // Encryption key
                        keyData.count, // Key length
                        ivBytes.baseAddress, // IV
                        passwordBytes.baseAddress, // Input data
                        passwordData.count, // Input data length
                        encryptedData.withUnsafeMutableBytes { encryptedBytes in
                            return encryptedBytes.baseAddress // Output buffer
                        },
                        encryptedData.count, // Output buffer size
                        &encryptedLength // Output actual encrypted length
                    )
                }
            }
        }
        
        // Check if encryption succeeded
        guard result == kCCSuccess else { return nil }
        
        // Trim the encrypted data to the actual encrypted length
        encryptedData.count = encryptedLength
        
        // Convert encrypted data to base64 string for storage
        return encryptedData.base64EncodedString()
    }

    static func decrypt(encryptedPassword: String, keyString: String, ivString: String = "") -> String? {
        // Convert the encrypted password string from base64
        guard let encryptedData = Data(base64Encoded: encryptedPassword) else { return nil }
        
        // Define key and initialization vector (IV)
        let keyString = keyString
        let ivyKey: String
        
        if ivString == ""{
            ivyKey = SettingsViewController.loadSettingByKey(key: "ivKey")!
        }else{
            ivyKey = ivString
        }
        
        // Convert key and IV strings to Data
        guard var keyData = keyString.data(using: .utf8), let ivData = Data(base64Encoded: ivyKey) else
        {
            return nil
        }
        keyData.count = kCCKeySizeAES128
        
        // Prepare buffers
        var decryptedData = Data(count: encryptedData.count + kCCBlockSizeAES128)
        var decryptedLength: Int = 0
        
        // Perform decryption
        let result = encryptedData.withUnsafeBytes { encryptedBytes in
            return ivData.withUnsafeBytes { ivBytes in
                return keyData.withUnsafeBytes { keyBytes in
                    return CCCrypt(
                        UInt32(kCCDecrypt), // Decrypt operation
                        UInt32(kCCAlgorithmAES), // AES algorithm
                        UInt32(kCCOptionPKCS7Padding), // Padding
                        keyBytes.baseAddress, // Decryption key
                        keyData.count, // Key length
                        ivBytes.baseAddress, // IV
                        encryptedBytes.baseAddress, // Input data
                        encryptedData.count, // Input data length
                        decryptedData.withUnsafeMutableBytes { decryptedBytes in
                            return decryptedBytes.baseAddress // Output buffer
                        },
                        decryptedData.count, // Output buffer size
                        &decryptedLength // Output actual decrypted length
                    )
                }
            }
        }
        
        // Check if decryption succeeded
        guard result == kCCSuccess else {
            print("Decryption error: \(result)")
            return nil
        }
        
        // Trim the decrypted data to the actual decrypted length
        decryptedData.count = decryptedLength
        
        // Convert decrypted data to string
        return String(data: decryptedData, encoding: .utf8)
    }


}

extension SettingsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? settingsTableViewCell {
            
            //print(cell.label.text ?? "")
            //print(cell.getText())
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
        cell.textField?.text = settingsValues[settings[indexPath.row]]
        
        cell.delegate = self
        
        return cell
    }
}

extension SettingsViewController: SettingsTableViewCellDelegate {
    func textFieldDidEndEditing(in cell: settingsTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            tableView.deselectRow(at: indexPath, animated: true)
            if let cell = tableView.cellForRow(at: indexPath) as? settingsTableViewCell {
                print(cell.label.text ?? "")
                print(cell.getText())
                
                let key = cell.label.text ?? ""
                let set = SettingsViewController.self
                
                let text = cell.getText()
                switch key {
                    case "First Name", "Last Name", "Email", "API Token":
                        settingsValues[key] = text
                        set.saveSettingToPlist(key: key, value: text)
                    case "Password":
                        if let encryptedPassword = set.encrypt(password: text, keyString: settingsValues["API Token"]!
                        ){
                            settingsValues["Password"] = text
                            set.saveSettingToPlist(key: "Password", value: encryptedPassword)
                        }else{
                            print("Could not save password (API Token needs to be populated first)")
                        }
                    default:
                        break
                }
                settingsDidChange?(settingsValues)
            }
        }
    }
}
