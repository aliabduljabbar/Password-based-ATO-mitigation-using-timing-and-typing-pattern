//
//  SplashViewController.swift
//  Tolerance
//
//  Created by Ali Abdul Jabbar on 18/05/2022.
//  Copyright © 2022 Ali Abdul Jabbar. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SplashViewController: UIViewController {

    var currentUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        currentUser = Auth.auth().currentUser
        if currentUser != nil {
            loadInfo()
        }else {
            transitionToLandingScreen()
        }
    }
    
    func loadInfo() {
        Firestore.firestore().collection("users").addSnapshotListener { (querySnapshot, error) in
            if let e = error {
                print("there was an issue retrieving the data\(e)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if Auth.auth().currentUser?.email == data["user-email"] as? String{
                            if let userEmail = data["user-email"] as? String {
                                DataManager.shared.user = userEmail
                            }
                            if let totalSessionsByUserAndDevice = data["total-sessions-by-user-and-device"] as? Int {
                                DataManager.shared.totalSessionsByUserAndDevice = totalSessionsByUserAndDevice
                            }
                            self.transitionToHomeScreen()
                        }
                    }
                }
            }
        }
    }
    
    func transitionToHomeScreen() {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
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
