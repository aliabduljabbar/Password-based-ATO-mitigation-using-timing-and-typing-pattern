//
//  SignInViewController.swift
//  Tolerance
//
//  Created by Ali Abdul Jabbar on 4/4/22.
//  Copyright © 2022 Ali Abdul Jabbar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignInViewController: UIViewController {

    @IBOutlet weak var emailOrPhoneTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var currentUser: User?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailOrPhoneTF.addLine(position: .LINE_POSITION_BOTTOM, color: #colorLiteral(red: 0.6666666667, green: 0.7137254902, blue: 0.7647058824, alpha: 1), width: 0.5)
        passwordTF.addLine(position: .LINE_POSITION_BOTTOM, color: #colorLiteral(red: 0.6666666667, green: 0.7137254902, blue: 0.7647058824, alpha: 1), width: 0.5)
    }
        
    @IBAction func signInPressed(_ sender: Any) {
        signIn()
    }
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.addLine(position: .LINE_POSITION_BOTTOM, color: #colorLiteral(red: 0.05098039216, green: 0.7137254902, blue: 0.3960784314, alpha: 1), width: 0.5)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.addLine(position: .LINE_POSITION_BOTTOM, color: #colorLiteral(red: 0.6666666667, green: 0.7137254902, blue: 0.7647058824, alpha: 1), width: 0.5)
    }
}

// MARK: - Signing in an user (Firebase auth and Firestore part)
extension SignInViewController {
    func signIn() {
        indicator.startAnimating()
        if let email = emailOrPhoneTF.text,
            let password = passwordTF.text {
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                self.indicator.stopAnimating()
                
                if let e = error {
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = e.localizedDescription
                    self.emailOrPhoneTF.addLine(position: .LINE_POSITION_BOTTOM, color: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), width: 0.5)
                    self.passwordTF.addLine(position: .LINE_POSITION_BOTTOM, color: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), width: 0.5)
                } else {
                    if Auth.auth().currentUser!.isEmailVerified {
                        self.loadInfo()
                    } else {
                        self.emailOrPhoneTF.text = "Your email is not verified"
                        self.emailOrPhoneTF.addLine(position: .LINE_POSITION_BOTTOM, color: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), width: 0.5)
                        self.passwordTF.addLine(position: .LINE_POSITION_BOTTOM, color: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), width: 0.5)
                    }
                }
            }
        }
    }
    
    func loadInfo() {
        let collectionReference = db.collection("users")
        if let userEmail = Auth.auth().currentUser?.email {
            let query:Query = collectionReference.whereField("user-email", isEqualTo: userEmail)
            query.getDocuments(completion: { (snapshot, error) in
                if let error = error {
                    print("ERRRRORRRRRR \(error.localizedDescription)")
                } else {
                    guard let user = snapshot?.documents.first else { return }
                    if let userEmail = user["user-email"] as? String {
                        DataManager.shared.user = userEmail
                    }
                    if let totalSessionsByUserAndDevice = user["total-sessions-by-user-and-device"] as? Int {
                        DataManager.shared.totalSessionsByUserAndDevice = totalSessionsByUserAndDevice
                    }
                    self.transitionToHomeScreen()
                }})
        }else {
            self.dismiss(animated: true)
        }
    }
    
    func transitionToHomeScreen() {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
}
