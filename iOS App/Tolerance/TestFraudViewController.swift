//
//  TestFraudViewController.swift
//  Tolerance
//
//  Created by Ali Abdul Jabbar on 12.05.2022.
//  Copyright © 2022 Ali Abdul Jabbar. All rights reserved.
//

import UIKit


class TestFraudViewController: UIViewController {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var buttonDone: UIButton!
    @IBOutlet private weak var viewRed: UIView!
    
    var isFraud: Bool? {
        didSet {
            if let val = isFraud {
                viewRed.backgroundColor = !val ? UIColor.red : UIColor.green;
                //viewGreen.alpha = val ? 1:0.05
                //viewRed.isHidden = !val;
                //viewGreen.isHidden = val;
            } else {
                viewRed.backgroundColor = UIColor.clear;
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {      
        DataManager.shared.cutTempForLastClick()
            if textField.text!.count > DataManager.shared.getPassLength() {
                //print("Changed for PLUS")
                DataManager.shared.flushAtoms()
            }
        if textField.text!.count < DataManager.shared.getPassLength() || textField.text!.count == 0 {
                //print("Changed for MINUS")
                DataManager.shared.deleteLastClick()
                DataManager.shared.clearTemp()
            }
        
        //print(DataManager.shared.atoms.count)
//        DataManager.shared.setPass(textField.text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewRed.backgroundColor = UIColor.clear;
        textField.addTarget(self, action: #selector(TestFraudViewController.textFieldDidChange(_:)),
        for: UIControl.Event.editingChanged)
        DataManager.shared.clear()
        DataManager.shared.clearTemp()
    }
    
    @IBAction func buttonDone(_ sender: Any) {
        textField.text = ""
//        DataManager.shared.setPass("")
        
                DataManager.shared.toleranceIdentityChecker(completion: { (json, error) in
                    
                    if let _ = error {
                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        
                        print("send data")
                        self.textField.resignFirstResponder()
                        self.textField.text = nil
                        
                        if let _json = json,
                            let fraudAlert = _json["fraud_alert"].string,
                            let _ = _json["session_id"].string {
                            self.isFraud = fraudAlert == "True";
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                self.isFraud = nil
                            })
                        }
                    }
                })
    }

    func alertPass() {
        let alert = UIAlertController(title: "Error", message: "Неверный пароль", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { (action) in
            //
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
