//
//  ViewController.swift
//  Tolerance
//
//  Created by Ali Abdul Jabbar on 4/29/22.
//  Copyright © 2022 Ali Abdul Jabbar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LandingViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var currentUser: User?
    
    let infoSliders = [InfoSlider(label1: "ATO Attacks mitigation using typing timing and pattern", title: "Sign In or Sign Up", subtitle: "Create an account and participate in the thesis")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pageControl.numberOfPages = infoSliders.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        currentUser = Auth.auth().currentUser
        if currentUser != nil {
            transitionToTabBar()
        }
    }
    
    func transitionToTabBar() {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated:true, completion:nil)
    }
    
    var currentIndex = 0
    
}

extension LandingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infoSliders.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoSliderCell", for: indexPath) as! InfoSliderCell
        
        cell.label1.text = infoSliders[indexPath.item].label1
        cell.title.text = infoSliders[indexPath.item].title
        cell.subtitle.text = infoSliders[indexPath.item].subtitle
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / collectionView.frame.size.width)
        pageControl.currentPage = currentIndex
    }
}

