//
//  SettingsViewController.swift
//  Tolerance
//
//  Created by Ali Abdul Jabbar on 24/05/2022.
//  Copyright © 2022 Ali Abdul Jabbar. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            showMessage(title: "Are you sure you want to logout?", message: "")
        } catch let logOutError as NSError {
            print("Log out error: ", logOutError)
        }
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        Settings.shared.serverIp = textField.text;
        return true;
    }
}

extension SettingsViewController {
    // Logout Helper Methods
    
    func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            if title != "Error" {
                self.transitionToLandingScreen()
            }
        }
        let no = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
    }
    
    func transitionToLandingScreen() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "LandingViewController")
        if #available(iOS 13.0, *) {
            nextViewController.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        self.present(nextViewController, animated:true, completion:nil)
    }
}
