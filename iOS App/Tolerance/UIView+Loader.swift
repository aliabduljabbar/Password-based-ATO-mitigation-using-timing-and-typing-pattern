//
//  UIView+Loader.swift
//  Tolerance
//
//  Created by Ali Abdul Jabbar on 11/06/2022.
//  Copyright © 2022 Ali Abdul Jabbar. All rights reserved.
//

import Foundation
import UIKit

enum LoadingViewBackgroundColor {
    case same
    case dim
}

extension UIView {
    static let loadingIndicatorViewTag = 1938123987
    static let loadingViewTag = 1938123987
    
    static let loadingIndicatorViewTag2 = 1938123988
    static let loadingViewTag2 = 1938123988
    
    func showLoading(color: UIColor?, scale: CGFloat = 1, animated: Bool = true, backgroundColorType: LoadingViewBackgroundColor = .same) {
        var bgColorView = viewWithTag(UIView.loadingViewTag)
        if bgColorView == nil {
            bgColorView = UIView()
            bgColorView?.tag = UIView.loadingViewTag
        }
        if backgroundColorType == .same {
            bgColorView?.backgroundColor = self.backgroundColor
        } else {
            bgColorView?.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        }
        bgColorView?.layer.cornerRadius = self.layer.cornerRadius
        UIView.transition(with: self, duration: 0.25, options: animated ? [.transitionFlipFromBottom, .curveEaseInOut] : [.curveEaseInOut, .transitionCrossDissolve], animations: {
          self.addSubview(bgColorView!)
        }, completion: nil)

        bgColorView?.translatesAutoresizingMaskIntoConstraints = false

        bgColorView?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        bgColorView?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        bgColorView?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bgColorView?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        var loading = bgColorView?.viewWithTag(UIView.loadingIndicatorViewTag) as? UIActivityIndicatorView
        if loading == nil {
            if #available(iOS 13.0, *) {
                loading = UIActivityIndicatorView(style: .medium)
            } else {
                loading = UIActivityIndicatorView(style: .white)
            }
        }

        loading?.transform = CGAffineTransform(scaleX: scale, y: scale)
        if let color = color {
            loading?.color = color
        }
        loading?.translatesAutoresizingMaskIntoConstraints = false
        loading!.startAnimating()
        loading!.hidesWhenStopped = true
        loading?.tag = UIView.loadingIndicatorViewTag
        bgColorView?.addSubview(loading!)
        loading?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loading?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    func stopLoading(animated: Bool = true) {
        let bgColorView = viewWithTag(UIView.loadingViewTag)
        let loading = viewWithTag(UIView.loadingIndicatorViewTag) as? UIActivityIndicatorView
        loading?.stopAnimating()
        UIView.transition(with: self, duration: 0.25, options: animated ? [.transitionFlipFromBottom, .curveEaseInOut] : [.curveEaseInOut, .transitionCrossDissolve], animations: {
          bgColorView?.removeFromSuperview()
        }, completion: nil)
    }
    
    
    func showLoadingForView(color: UIColor?, scale: CGFloat = 1, animated: Bool = true, backgroundColorType: LoadingViewBackgroundColor = .same, autoDisable: Bool = false, timeForDisable: DispatchTime = .now() + 6) {
        var bgColorView = viewWithTag(UIView.loadingViewTag2)
        if bgColorView == nil {
            bgColorView = UIView()
            bgColorView?.tag = UIView.loadingViewTag2
        }
       
        bgColorView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
//        bgColorView?.cornerRadius = self.cornerRadius
//        UIView.transition(with: self, duration: 0.25, options: animated ? [.transitionFlipFromBottom, .curveEaseInOut] : [.curveEaseInOut, .transitionCrossDissolve], animations: {
//          self.addSubview(bgColorView!)
//        }, completion: nil)

        self.addSubview(bgColorView!)
        bgColorView?.translatesAutoresizingMaskIntoConstraints = false

        bgColorView?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        bgColorView?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        bgColorView?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bgColorView?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        var loading = bgColorView?.viewWithTag(UIView.loadingIndicatorViewTag2) as? UIActivityIndicatorView
        if loading == nil {
            if #available(iOS 13.0, *) {
                loading = UIActivityIndicatorView(style: .large)
            } else {
                // Fallback on earlier versions
            }
        }
//
//        loading?.transform = CGAffineTransform(scaleX: scale, y: scale)
//        if let color = color {
//            loading?.color = color
//        }
        loading?.translatesAutoresizingMaskIntoConstraints = false
        loading!.startAnimating()
        loading!.hidesWhenStopped = true
        loading?.tag = UIView.loadingIndicatorViewTag2
        bgColorView?.addSubview(loading!)
        loading?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loading?.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        
        if autoDisable {
            DispatchQueue.main.asyncAfter(deadline:  timeForDisable) {
                self.stopLoadingForView()
            }
        }
    }

    func stopLoadingForView(animated: Bool = true) {
        let bgColorView = viewWithTag(UIView.loadingViewTag2)
        let loading = viewWithTag(UIView.loadingIndicatorViewTag2) as? UIActivityIndicatorView
        loading?.stopAnimating()
        bgColorView?.removeFromSuperview()
    }
}
