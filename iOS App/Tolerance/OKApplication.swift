//
//  OKApplication.swift
//  Tolerance
//
//  Created by Ali Abdul Jabbar on 04.03.2022.
//  Copyright © 2022 Ali Abdul Jabbar. All rights reserved.
//

import UIKit
import CoreMotion
import SceneKit

protocol OKApplicationDelegate: class {
    func newAtomData(atomData data:Atom) -> Void
}

protocol OKDispalyMotionDelegate: class {
    func displayMotion(accelerator: CMAccelerometerData, gyro: CMGyroData, motion: CMDeviceMotion) -> Void
    func displayTouch(touch: UITouch) -> Void
}

final class KeyboardManager {

    static let shared = KeyboardManager()

    private init() { }

    /// Returns keyboard view on application window
    ///
    /// - Returns: Keyboard view
    func keyboardView() -> UIView? {
        for window in UIApplication.shared.windows {
            if let keyboardView = keyboardViewFromWindow(window) {
                return keyboardView
            }
        }
        return nil
    }

    /// Returns keyboard view from given window
    ///
    /// - Parameter window: Keyboard view container candidate window
    /// - Returns: Keyboard view
    func keyboardViewFromWindow(_ window: UIWindow) -> UIView? {
        if window.hasClassNameSuffix("UIRemoteKeyboardWindow") {
            let inputSetContainerView = window.subview(withSuffix: "InputSetContainerView")
            let inputSetHostView = inputSetContainerView?.subview(withSuffix: "InputSetHostView")
            return inputSetHostView
        }

        return nil
    }
    
    func keyboardButtons(_ view: UIView?) -> [UIView]? {
        if let v = view {
            if v.hasClassNameSuffix("UIKeyboardLayoutStar") {
                let buttons = v.subviews.first?.subviews.filter({ $0.hasClassNameSuffix("UIKBKeyView")});
                return buttons
            }
        }
        return nil
    }
    
    func indexOfButtonAtPoint(_ point:CGPoint, in view: UIView) -> NSInteger {
        var index = NSNotFound;
        if let buttons = self.keyboardButtons(view) {
            buttons.enumerated().forEach { (idx, item) in
                if item.hasClassNameSuffix("UIKBKeyView") && item.frame.contains(point) {
                    index = idx
                }
            }
        }
        return index
    }
    
    func buttonAtPoint(_ point:CGPoint, in view: UIView) -> UIView? {
        var button:UIView? = nil
        if let buttons = self.keyboardButtons(view) {
            buttons.enumerated().forEach { (idx, item) in
                if item.frame.contains(point) {
                    button = item
                }
            }
        }
        return button
    }
    
}

@nonobjc extension UIView {

    /// Returns first found subview with given class name
    ///
    /// - Parameter className: Subview class name
    /// - Returns: First subview with given class name
    func subview(withSuffix className: String) -> UIView? {
        return subviews.first {
            $0.hasClassNameSuffix(className)
        }
    }

    /// Compares suffix of view class name with given name
    ///
    /// - Parameter className: Class name that will be compared
    /// - Returns: Comparison result of view class name and given name
    func hasClassNameSuffix(_ className: String) -> Bool {
        return NSStringFromClass(type(of: self)).hasSuffix(className)
    }
}

class OKApplication: UIApplication {
    
    private var motionManager: CMMotionManager!
    private var motionTimer: Timer!
    private var displayTimer: Timer!
    
    public weak var atomDelegate: OKApplicationDelegate?
    public weak var displayDelegate: OKDispalyMotionDelegate?
    
    override init() {
        super.init()
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.startDeviceMotionUpdates()
        
        initMotionTimer()
        
        displayTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(displayTimerFire(_:)), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(settingsChanged(_:)), name: Notification.Name(Settings.settingsChangedNotification), object: nil)
    }
    
    deinit {
        motionTimer.invalidate()
        displayTimer.invalidate()
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
    
    private func initMotionTimer() {
    
        let ti = TimeInterval(1 / Double(Settings.shared.accelFreq == 0 ? 1:Settings.shared.accelFreq))
        if motionTimer != nil {
            motionTimer.invalidate()
        }
        motionTimer = Timer.scheduledTimer(timeInterval: ti,
                                           target: self,
                                           selector: #selector(motionTimerFire(_:)),
                                           userInfo: nil, repeats: true)
    }
    
    @objc func motionTimerFire(_ timer: Timer) {
        if let accelerometerData = motionManager.accelerometerData, let gyroData = motionManager.gyroData, let deviceMotion = motionManager.deviceMotion {
            
            DataManager.shared.addAtom(Atom(touch: nil,
                                            keyString: nil,
                                            accelerometer: accelerometerData,
                                            gyro: gyroData,
                                            motion: deviceMotion))
        }
        //print("fire")
        
    }
    
    @objc func displayTimerFire(_ timer: Timer) {
        if let accelerometerData = motionManager.accelerometerData,
            let gyroData = motionManager.gyroData,
            let deviceMotion = motionManager.deviceMotion,
            let delegate = self.displayDelegate {
            
            delegate.displayMotion(accelerator: accelerometerData, gyro: gyroData, motion: deviceMotion)
        }
    }
    
    @objc func settingsChanged(_ notify:Notification) {
        initMotionTimer()
    }
    
    override func sendEvent(_ event: UIEvent) {
        
        if let touches = event.allTouches {
            for touch in touches {
                if let touchedView = touch.view {
                    let locationTouched = touch.location(in: touchedView)
                    
                    if let button =  KeyboardManager.shared.buttonAtPoint(locationTouched, in: touchedView), let key = ((button.value(forKey: "m_key") as? AnyObject)?.value(forKey: "properties") as? AnyObject)?.value(forKey: "KBdisplayString") as? String {
                        let atom = Atom(touch: touch,
                                        keyString: key,
                                        accelerometer: self.motionManager.accelerometerData,
                                        gyro: self.motionManager.gyroData,
                                        motion: self.motionManager.deviceMotion)
                        
                        //print("touch ", atom.jsonTouch!["phase"])
                        DataManager.shared.addAtom(atom)
                    }
                }
                
                if let delegate = self.displayDelegate {
                    delegate.displayTouch(touch: touch)
                }
            }
        }
        super.sendEvent(event)
    }    
}
