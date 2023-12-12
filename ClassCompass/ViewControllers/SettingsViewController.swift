//
//  SettingsViewController.swift
//  ClassCompass
//
//  Created by Matteo Catalano on 11/30/23.
//

import UIKit
import Foundation
import CommonCrypto

/**
 `SettingsViewController` is a UIViewController subclass that manages and displays user settings.

 It has the following properties:
 - `db`: A Database object that is used to interact with the database.
 - `settings`: An array of strings that represent the names of the settings.
 - `settingsValues`: A dictionary that maps setting names to their current values.
 - `settingsDidChange`: A closure that is called when a setting's value changes.
 - `tableView`: An IBOutlet for the UITableView that displays the settings.

 In `viewDidLoad`, it initializes the `settingsValues` dictionary with empty strings for any settings that don't already have a value. If the "Password" and "API Token" settings have values, it decrypts the password and stores the decrypted password back in `settingsValues`.

 It also registers a custom UITableViewCell for use with the table view, and sets itself as the table view's delegate.
 */
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
    
    /**
     This method is called after the view controller's view is loaded into memory.
     It initializes the settings values dictionary, decrypts the password if it is not empty, and sets up the table view.
     */
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
    
    /**
     Saves a setting to the Settings.plist file.

     - Parameters:
         - key: The key for the setting.
         - value: The value to be saved for the setting.

     This function checks if the Settings.plist file exists. If it does, it loads its contents into a mutable dictionary. It then updates the value for the specified key in the dictionary and writes the updated dictionary back to the plist file. If the file doesn't exist, it creates a new dictionary with the specified key-value pair and writes it to the plist file.

     - Note: The Settings.plist file should be located in the document directory of the user's app.
     - Important: The function assumes that the value parameter is of type Any, but it is recommended to use a specific type for the value parameter to ensure type safety.
     */
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
    
    /// Loads the settings from a plist file and returns them as a dictionary.
    /// - Returns: A dictionary containing the settings loaded from the plist file, or `nil` if the file doesn't exist or couldn't be loaded.
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
    
    /// Loads a setting value from the settings dictionary based on the specified key.
    /// - Parameter key: The key to search for in the settings dictionary.
    /// - Returns: The value associated with the specified key, or `nil` if the key does not exist.
    static func loadSettingByKey(key: String) -> String? {
        
        if let settingsDict = SettingsViewController.loadSettingsFromPlist() {
            if let value = settingsDict[key] {
                return value // Return value for the specified key
            } else {
                print("Key '\(key)' does not exist in the settings")
            }
        } else {
            print("Error loading settings")
        }
        return nil
    }

    /// Generates a random initialization vector (IV) for AES encryption.
    /// - Returns: The randomly generated initialization vector as `Data`.
    static func generateRandomIV() -> Data {
        var randomIV = [UInt8](repeating: 0, count: kCCBlockSizeAES128)
        let result = SecRandomCopyBytes(kSecRandomDefault, randomIV.count, &randomIV)
        assert(result == errSecSuccess, "Failed to generate random bytes")
        return Data(randomIV)
    }
    
    /**
     Encrypts a password using AES encryption algorithm.

     - Parameters:
         - password: The password to be encrypted.
         - keyString: The key used for encryption.

     - Returns: The encrypted password as a base64-encoded string, or `nil` if encryption fails.
     */
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

    /**
     Decrypts an encrypted password using AES algorithm with the provided key and initialization vector (IV).

     - Parameters:
         - encryptedPassword: The encrypted password string to be decrypted.
         - keyString: The key string used for decryption.
         - ivString: The initialization vector (IV) string used for decryption. If not provided, it will be loaded from the "ivKey" setting.

     - Returns: The decrypted password string, or nil if decryption fails.
     */
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

/**
    Extension of SettingsViewController conforming to UITableViewDelegate protocol.
*/
extension SettingsViewController: UITableViewDelegate {
    
    /**
        Called when a row is deselected in the table view.
     
        - Parameters:
            - tableView: The table view object.
            - indexPath: The index path of the deselected row.
    */
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? settingsTableViewCell {
            
            //print(cell.label.text ?? "")
            //print(cell.getText())
        }
    }
}

/// Extension of SettingsViewController conforming to UITableViewDataSource protocol.
extension SettingsViewController: UITableViewDataSource {
    
    /// Returns the number of rows in the table view section.
    /// - Parameters:
    ///   - tableView: The table view object requesting this information.
    ///   - section: An index number identifying a section of the table view.
    /// - Returns: The number of rows in the specified section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    /// - Parameters:
    ///   - tableView: The table view object requesting the cell.
    ///   - indexPath: An index path locating a row in tableView.
    /// - Returns: An object inheriting from UITableViewCell that the table view can use for the specified row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsTableViewCell", for: indexPath) as! settingsTableViewCell
        
        cell.label?.text = settings[indexPath.row]
        cell.textField?.text = settingsValues[settings[indexPath.row]]
        
        cell.delegate = self
        
        return cell
    }
}

/// Extension of SettingsViewController conforming to SettingsTableViewCellDelegate protocol.
extension SettingsViewController: SettingsTableViewCellDelegate {
    
    /**
     Handles the event when the text field in a settingsTableViewCell ends editing.
     
     - Parameter cell: The settingsTableViewCell that triggered the event.
     */
    func textFieldDidEndEditing(in cell: settingsTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            tableView.deselectRow(at: indexPath, animated: true)
            if let cell = tableView.cellForRow(at: indexPath) as? settingsTableViewCell {
                // Print the label text and the text entered in the cell's text field
                print(cell.label.text ?? "")
                print(cell.getText())
                
                let key = cell.label.text ?? ""
                let set = SettingsViewController.self
                
                let text = cell.getText()
                switch key {
                    case "First Name", "Last Name", "Email", "API Token":
                        // Update the settings value and save it to the plist file
                        settingsValues[key] = text
                        set.saveSettingToPlist(key: key, value: text)
                    case "Password":
                        // Encrypt the password and save it to the plist file
                        if let encryptedPassword = set.encrypt(password: text, keyString: settingsValues["API Token"]!) {
                            settingsValues["Password"] = text
                            set.saveSettingToPlist(key: "Password", value: encryptedPassword)
                        } else {
                            print("Could not save password (API Token needs to be populated first)")
                        }
                    default:
                        break
                }
                // Call the settingsDidChange closure to notify that the settings values have been updated
                settingsDidChange?(settingsValues)
            }
        }
    }
}
