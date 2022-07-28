//
//  Atom.swift
//  Tolerance
//
//  Created by Ali Abdul Jabbar on 06.03.2022.
//  Copyright © 2022 Ali Abdul Jabbar. All rights reserved.
//

import UIKit
import CoreMotion
import SceneKit
import SwiftyJSON

private struct Static {
    static var tagTextField = 10
    static var tagMainView = 11
    static var tagButtonDone = 12
}

class Atom: NSObject {
    
    var id: String
    var key:String?
    var touchObject: UITouch?
    var jsonTouch: JSON?
    var jsonAccelerometer: JSON?
    var jsonGyro: JSON?
    var jsonMotion: JSON?
    var brightness: CGFloat?
    
    
    var json: JSON {
        get {
            let json: JSON = ["touch": jsonTouch ?? "NULL",
                              "key":key ?? "",
                              "accelerometer": jsonAccelerometer ?? "NULL",
                              "gyro": jsonGyro ?? "NULL",
                              "motion": jsonMotion ?? "NULL"]
            return json
        }
    }
    
    var preciseJSON: JSON {
        get {
            let json: JSON = ["touch": jsonTouch ?? "NULL",
                              "key":key ?? "",
                              "accelerometer": jsonAccelerometer ?? "NULL",
                              "gyro": jsonGyro ?? "NULL",
                              "motion": jsonMotion ?? "NULL"]
            return json
        }
    }
    
    override init() {
        id = UUID().uuidString
    }
    
    convenience init(touch: UITouch?, keyString:String?, accelerometer: CMAccelerometerData?, gyro: CMGyroData?, motion: CMDeviceMotion?) {
        self.init()
        touchObject = touch
        jsonTouch = touch?.json
        key = keyString
        jsonAccelerometer = accelerometer?.json(timestamp: touch?.timestamp ?? ProcessInfo.processInfo.systemUptime)
        jsonGyro = gyro?.json(timestamp: touch?.timestamp ?? ProcessInfo.processInfo.systemUptime)
        jsonMotion = motion?.json(timestamp: touch?.timestamp ?? ProcessInfo.processInfo.systemUptime)
    }
    
    var isBegan: Bool {
        jsonTouch?["phase"] == "began"
    }
    
    var isEnded: Bool {
        jsonTouch?["phase"] == "ended"
    }
    
}

extension UITouch {
    
    public var json: JSON {
        get {
            var json: JSON = ["timestamp": self.timestamp,
                              "majorRadius": self.majorRadius,
                              "majorRadiusTolerance": self.majorRadiusTolerance,
                              "force": self.force,
                              "phase": self.phaseDescription]
            
            var jsonView: JSON = JSON()
            switch view?.tag {
            case Static.tagTextField:
                jsonView["name"] = "textField"
            case Static.tagMainView:
                jsonView["name"] = "mainView"
            case Static.tagButtonDone:
                jsonView["name"] = "buttonDone"
            default:
                jsonView["name"] = "otherView"
                break
            }
            
            if let _ = jsonView["name"].string {
                let location = self.location(in: (view?.tag != 0 ? view : (UIApplication.shared.delegate?.window)!))
                let jsonLocation: JSON = ["x":location.x, "y":location.y]
                let jsonPosition: JSON = ["origin": ["x":view?.frame.origin.x, "y":view?.frame.origin.y],
                                          "size":   ["width":view?.frame.size.width, "height":view?.frame.size.height]]
                
                jsonView["location"] = jsonLocation
                jsonView["position"] = jsonPosition
                
                json["source"] = jsonView
            }
            
            return json
        }
    }
    
    private var phaseDescription: String {
        get {
            switch phase {
            case .began:
                return "began"
            case .ended:
                return "ended"
            case .moved:
                return "moved"
            case .stationary:
                return "stationary"
            case .cancelled:
                return "cancelled"
            @unknown default:
                return "";
            }
        }
    }
}

extension CMAccelerometerData {
    
    public var json: JSON {
        get {
            let json = JSON(["x": acceleration.x,
                             "y": acceleration.y,
                             "z": acceleration.z])
            return json
        }
    }
    
    func json(timestamp ti:TimeInterval?) -> JSON {
        var json = self.json
        guard let _ = ti else { return json}
        json["timestamp"].doubleValue = ti!
        return json
    }
    
}

extension CMGyroData {
    public var json: JSON {
        get {
            let json = JSON(["x": rotationRate.x,
                             "y": rotationRate.y,
                             "z": rotationRate.z])
            return json
        }
    }
    
    func json(timestamp ti:TimeInterval?) -> JSON {
        var json = self.json
        guard let _ = ti else { return json}
        json["timestamp"].doubleValue = ti!
        return json
    }
}

extension CMDeviceMotion {
    public var json: JSON {
        get {
            let json = JSON(["attitude": JSON(["roll": attitude.roll,
                                               "pitch": attitude.pitch,
                                               "yaw": attitude.yaw]),
                             
                             "rotationRate": JSON(["x": rotationRate.x,
                                                   "y": rotationRate.y,
                                                   "z": rotationRate.z]),
                             
                             "gravity": JSON(["x": gravity.x,
                                              "y": gravity.y,
                                              "z": gravity.z]),
                             
                             "userAcceleration": JSON(["x": userAcceleration.x,
                                                       "y": userAcceleration.y,
                                                       "z": userAcceleration.z])
                             
                             ])
            return json
        }
    }
    
    func json(timestamp ti:TimeInterval?) -> JSON {
        var json = self.json
        guard let _ = ti else { return json}
        json["timestamp"].doubleValue = ti!
        return json
    }
}
