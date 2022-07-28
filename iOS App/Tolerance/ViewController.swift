//
//  ViewController.swift
//  Tolerance
//
//  Created by Ali Abdul Jabbar on 04.03.2022.
//  Copyright © 2022 Ali Abdul Jabbar. All rights reserved.
//

import UIKit
import CoreMotion
import Firebase
import FirebaseAuth

class ViewController: UIViewController, OKDispalyMotionDelegate {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var buttonDone: UIButton!
    
    @IBOutlet private weak var info1: UILabel!
    @IBOutlet private weak var info2: UILabel!
    @IBOutlet private weak var info3: UILabel!
    @IBOutlet private weak var info4: UILabel!
    
    @IBOutlet private weak var infoAccelX: UILabel!
    @IBOutlet private weak var infoAccelY: UILabel!
    @IBOutlet private weak var infoAccelZ: UILabel!
    
    @IBOutlet private weak var infoGyroX: UILabel!
    @IBOutlet private weak var infoGyroY: UILabel!
    @IBOutlet private weak var infoGyroZ: UILabel!
    
    @IBOutlet private weak var infoMAttitudeRoll: UILabel!
    @IBOutlet private weak var infoMAttitudePitch: UILabel!
    @IBOutlet private weak var infoMAttitudeYaw: UILabel!
    
    @IBOutlet private weak var infoMRotationRateX: UILabel!
    @IBOutlet private weak var infoMRotationRateY: UILabel!
    @IBOutlet private weak var infoMRotationRateZ: UILabel!
    
    @IBOutlet private weak var infoMUserAccelX: UILabel!
    @IBOutlet private weak var infoMUserAccelY: UILabel!
    @IBOutlet private weak var infoMUserAccelZ: UILabel!
    
    @IBOutlet private weak var infoMGravityX: UILabel!
    @IBOutlet private weak var infoMGravityY: UILabel!
    @IBOutlet private weak var infoMGravityZ: UILabel!
    
    @IBOutlet private weak var infoRadius: UILabel!
    @IBOutlet private weak var infoRadiusTolerance: UILabel!
    @IBOutlet private weak var infoForce: UILabel!
    
    let application: OKApplication! = UIApplication.shared as? OKApplication
    
    var passwords:[TrainingPasswordModel] = []
    var currentPasswordIndex:Int = -1
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        // print("test")
//        DataManager.shared.cutTempForLastClick()
        if textField.text!.count > DataManager.shared.getPassLength() {
            //print("Changed for PLUS")
            DataManager.shared.flushAtoms()
        }
//        if textField.text!.count < DataManager.shared.getPassLength() || textField.text!.count == 0 {
//            //print("Changed for MINUS")
//            DataManager.shared.deleteLastClick()
//            DataManager.shared.clearTemp()
//        }
        print(DataManager.shared.atoms.count)
//        DataManager.shared.setPass(textField.text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.infoRadius.text = " "
        self.infoRadiusTolerance.text = " "
        self.infoForce.text = " "
        self.textField.isEnabled = false
        self.buttonDone.isEnabled = false
        
        self.info1.text = "USER: \(DataManager.shared.user ?? "")"
        self.info3.text = "\(DataManager.shared.deviceId)"
        self.info4.text = "[\(DataManager.shared.totalSessionsByUserAndDevice ?? 0)]"
        generateAndAssignPass()
        application.displayDelegate = self
     }
    
    fileprivate func loadTrainingPassword() {
        currentPasswordIndex+=1
        if currentPasswordIndex >= passwords.count {
            currentPasswordIndex = 0
        }
        
        DataManager.shared.pass = passwords[currentPasswordIndex].password
        self.info2.text = "\(DataManager.shared.pass ?? "Not Available")"
        self.textField.isEnabled = true
        self.buttonDone.isEnabled = true
    }
    
    func generateAndAssignPass() {
        guard self.passwords.isEmpty else { self.loadTrainingPassword(); return }
        self.loadTrainingPasswords { [weak self] passwords in
            self?.passwords = passwords
            self?.loadTrainingPassword()
        }
    }

    @IBAction func buttonDone(_ sender: Any) {
        self.textField.resignFirstResponder()
        guard DataManager.shared.pass == textField.text else {
            let action = UIAlertController(title: "Error", message: "please enter the correct password to add it in the training data", preferredStyle: .alert)
            action.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { _ in
                self.textField.text = nil
                DataManager.shared.atoms.removeAll()
            }))
            self.present(action, animated: true)
            return
        }
        self.buttonDone.showLoading(color: .white)
        DataManager.shared.sendData { (response) in
            print("send data")
            self.buttonDone.stopLoading()
            self.generateAndAssignPass()
            self.textField.text = nil
            if let response = response {
                self.info4.text = "Sent: [\(response["total-sessions-by-user-and-device"])]"
            } else {
                self.info4.text = "Mistake"
            }
            DataManager.shared.atoms.removeAll()
        }
    }
    
    // MARK: - OKDispalyMotionDelegate -
    func displayMotion(accelerator: CMAccelerometerData, gyro: CMGyroData, motion: CMDeviceMotion) {
        DispatchQueue.main.async {
            self.infoAccelX.text = String(format: "%.4f", accelerator.acceleration.x);
            self.infoAccelY.text = String(format: "%.4f", accelerator.acceleration.y);
            self.infoAccelZ.text = String(format: "%.4f", accelerator.acceleration.z);
            
            self.infoGyroX.text = String(format: "%.4f", gyro.rotationRate.x);
            self.infoGyroY.text = String(format: "%.4f", gyro.rotationRate.y);
            self.infoGyroZ.text = String(format: "%.4f", gyro.rotationRate.z);
            
            self.infoMAttitudeRoll.text = String(format: "%.4f", motion.attitude.roll);
            self.infoMAttitudePitch.text = String(format: "%.4f", motion.attitude.pitch);
            self.infoMAttitudeYaw.text = String(format: "%.4f", motion.attitude.yaw);
            
            self.infoMRotationRateX.text = String(format: "%.4f", motion.rotationRate.x);
            self.infoMRotationRateY.text = String(format: "%.4f", motion.rotationRate.y);
            self.infoMRotationRateZ.text = String(format: "%.4f", motion.rotationRate.z);
            
            self.infoMUserAccelX.text = String(format: "%.4f", motion.userAcceleration.x);
            self.infoMUserAccelY.text = String(format: "%.4f", motion.userAcceleration.y);
            self.infoMUserAccelZ.text = String(format: "%.4f", motion.userAcceleration.z);
            
            self.infoMGravityX.text = String(format: "%.4f", motion.gravity.x);
            self.infoMGravityY.text = String(format: "%.4f", motion.gravity.y);
            self.infoMGravityZ.text = String(format: "%.4f", motion.gravity.z);
            
        }
        
    }
    
    func displayTouch(touch: UITouch) {
        DispatchQueue.main.async {
            if touch.phase == .ended {
                self.infoRadius.text = " ";
                self.infoRadiusTolerance.text = " ";
                self.infoForce.text = " ";
            } else {
                self.infoRadius.text = String(format: "%.4f", touch.majorRadius);
                self.infoRadiusTolerance.text = String(format: "%.4f", touch.majorRadiusTolerance);
                self.infoForce.text = String(format: "%.4f", touch.force);
            }
        }
    }
}

extension ViewController {
    
    func loadTrainingPasswords(completion: @escaping ([TrainingPasswordModel]) -> Void) {
        Firestore.firestore().collectionGroup("training-passwords").getDocuments { (snapshot, error) in
            if let error = error {
                print("ERRRRORRRRRR \(error.localizedDescription)")
                completion([])
            } else {
                var passwords:[TrainingPasswordModel] = []
                for document in snapshot?.documents ?? [] {
                    if let password = document["password"] as? String {
                        passwords.append(TrainingPasswordModel(password: password))
                    }
                }
                completion(passwords)
            }
        }
    }
}
