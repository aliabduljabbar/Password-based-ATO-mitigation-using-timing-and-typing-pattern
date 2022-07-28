//
//  DataManager.swift
//  Tolerance
//
//  Created by Ali Abdul Jabbar on 11.03.2022.
//  Copyright © 2022 Ali Abdul Jabbar. All rights reserved.
//

import UIKit
import CoreMotion
import Alamofire
import SwiftyJSON
import Firebase
import FirebaseAuth

private struct Static {
    static let schema = "http://"
    static let server = "192.168.75.195:8080"
    static let service = "ToleranceDataReciever"
}

/* User registration
 http://185.246.65.33:8080/ToleranceDataReciever/registeruser
Input:
{
    "device_id" : "DF0B8CDC-F877-4087-8C4D-DDA2E8512D46"
}
Out:
{
            "username": "User1",
            "textvalue": "901734"
}
*/

/*
 http://185.246.65.33:8080/ToleranceDataReciever/toleranceidentitychecker
 Input:
 {
    "device_id" : "DF0B8CDC-F877-4087-8C4D-DDA2E8512D46"
 }
 Out:
 {
     "fraud_alert": "True",
     "session_id": "12345"
 }
 */


class DataManager {

    static let shared = DataManager()
    let db = Firestore.firestore()

    var server: URLConvertible {
        if let serverIP = Settings.shared.serverIp {
            return "\(Static.schema)\(serverIP)/\(Static.service)"
        }
        
        return "\(Static.schema)\(Static.server)/\(Static.service)"
    }
    
    public var deviceId: String {
        get {
            return UIDevice.current.identifierForVendor?.uuidString ?? "NULL"
        }
    }
    
    
    var atoms: [Atom]
    var atoms_temp: [Atom]
    var storedAtomsCount: [Int]
    var storedCurrentCounter: Int
    
    private init() {
        self.passValue = ""
        self.storedAtomsCount = []
        self.atoms = []
        self.atoms_temp = []
        self.storedCurrentCounter = 0
    }
    
    public func setPass(_ passtw: String?){
        self.passValue = passtw
    }
    
    var passValue: String?
    
    public var user: String?
    public var totalSessionsByUserAndDevice: Int?
    public var pass: String?
    public var inputs: Int = 0
    
    public func flushAtoms() {
        // print("temp:")
        // print(atoms_temp)
        atoms += atoms_temp
        atoms_temp = []
        storedAtomsCount.append(storedCurrentCounter)
        storedCurrentCounter = 0
    }
    
    public func deleteLastClick() {
        let needToDelete = storedAtomsCount.last ?? 0
        storedAtomsCount = (storedAtomsCount.dropLast())
        atoms = Array(atoms.dropLast(needToDelete))
    }
    
    public func printAtoms() {
        for atom in atoms {
            print(atom.json)
        }
    }
    
    public func getPassLength() -> Int {
        if self.passValue == nil {
            return 0
        } else {
            return self.passValue!.count
        }
    }
    
    public func clearTemp() {
        atoms_temp = []
        storedCurrentCounter = 0
//        setPass("")
        //print("!!!clearing temp atoms")
    }
    
    public func cutTempForLastClick() {
        //print("!!!cutting temp for only one last click")
        var endedIndex = -1
        for (index, value) in atoms_temp.enumerated().reversed() {
            if value.jsonTouch!["phase"] == "ended" {
                endedIndex = index
            }
            if value.jsonTouch!["phase"] == "began" && endedIndex != -1 {
                atoms_temp = Array(atoms_temp[index...endedIndex])
                break
            }
        }
    }
    
    public func addAtom(_ atom: Atom!) {
        // printAtoms()
        if let jsonTouch = atom.jsonTouch {
            if jsonTouch["source"]["name"] == "otherView" {
                atoms_temp.append(atom)
                storedCurrentCounter += 1
            }
        }
    }
    
    public func clear() {
        atoms = []
        //print("clearing atoms")
    }
    
    public func sendData(completion handle: ((_ responce: JSON?) -> Void)?)  {
        print("Send [\(atoms.count)] atoms")
        
        var dataAtoms: [Any] = []
        for atom in atoms {
            dataAtoms.append(atom.json)
        }
    
        let json: JSON = ["user": user ?? "NULL",
                          "textValue": pass ?? "NULL",
                          "deviceID": deviceId,
                          "timestamp": Date().timeIntervalSince1970,
                          "model": UIDevice.modelName,
                          "os": UIDevice.current.systemVersion,
                          "items": dataAtoms]
        
        let sendUnprocessedData = {
            self.db.collection("type-data").addDocument(data: json.dictionaryObject ?? [:]) { error in
            if error == nil {
                let collectionReference = self.db.collection("users")
                DataManager.shared.totalSessionsByUserAndDevice = (DataManager.shared.totalSessionsByUserAndDevice ?? 0)+1
                let sentDataCount = (DataManager.shared.totalSessionsByUserAndDevice ?? 0)
                if let userEmail = Auth.auth().currentUser?.email {
                    let query:Query = collectionReference.whereField("user-email", isEqualTo: userEmail)
                    query.getDocuments(completion: { (snapshot, error) in
                        if let error = error {
                            print("ERRRRORRRRRR \(error.localizedDescription)")
                        } else {
                            if let user = snapshot?.documents.first {
                                self.db.collection("users").document("\(user.documentID)").updateData(["total-sessions-by-user-and-device": sentDataCount])
                            }
                        }})
                }
                var json: JSON?
                json = JSON(["total-sessions-by-user-and-device":sentDataCount])
                if let _handle = handle {
                    _handle(json)
                }
            }
        }}
        
        struct AtomBeganAndEndedStruct {
            var began:Atom?
            var ended:Atom?
            var allAtoms:[Atom]
            var key:String
        }
        
        var dict:[String:Any] = [:]
        var holdTimeArray:[Double] = []
        var pressureArray:[Double] = []
        var touchRadiusArray:[Double] = []
        
        var mutableAtoms = atoms
        var previousTraversedAtomItem:AtomBeganAndEndedStruct? = nil
        for char in Array(pass ?? "") {
            guard let firstBeganIndex = mutableAtoms.firstIndex(where: { $0.isBegan && $0.key == String(char) }) else { return }
            guard let firstEndedIndex = mutableAtoms.firstIndex(where: { $0.isEnded && $0.key == String(char) }) else { return }
            let characterAtoms = mutableAtoms[firstBeganIndex...firstEndedIndex]
            print("👉🏻 mutableAtoms count : \(mutableAtoms.count)")
            mutableAtoms.removeAll(where: { atom in characterAtoms.contains(where: { $0.id == atom.id }) })
            print("👉🏻 mutableAtoms count after removing : \(mutableAtoms.count)")
            let beginAtom = characterAtoms.first(where: { $0.isBegan })
            let endedAtom = characterAtoms.first(where: { $0.isEnded })
            guard let key = beginAtom?.key else {
                print("💀begin key is not available💀")
                return
            }
            
            // check for the key
            guard characterAtoms.filter({ $0.key != key }).count == 0 else {
                print("💀keys are different\nbegin key is \(beginAtom?.key ?? "")\ndifferent keys are \(characterAtoms.compactMap({ $0.key }))💀")
                return
            }
            
            let holdTime: TimeInterval = (endedAtom?.jsonTouch?["timestamp"].doubleValue ?? 0.0) - (beginAtom?.jsonTouch?["timestamp"].doubleValue ?? 0.0)
            dict["Hold.\(key)"] = holdTime
            holdTimeArray.append(holdTime)
            
            let keyForces = characterAtoms.map({ $0.jsonTouch?["force"].doubleValue ?? 0.0 })
            let pressure: CGFloat = keyForces.reduce(0.0, +) / Double(keyForces.count)//((beginAtom?.jsonTouch?["force"].doubleValue ?? 0.0) + (endedAtom?.jsonTouch?["force"].doubleValue ?? 0.0))/2
            dict["Pressure.\(key)"] = pressure
            pressureArray.append(pressure)
            
            let keyRadiuses = characterAtoms.map({ $0.jsonTouch?["majorRadius"].doubleValue ?? 0.0 })
            let touchRadius: CGFloat = keyRadiuses.reduce(0.0, +) / Double(keyRadiuses.count)//((beginAtom?.touchObject?.majorRadius ?? 0.0) + (endedAtom?.touchObject?.majorRadius ?? 0.0))/2
            dict["Size.\(key)"] = touchRadius
            touchRadiusArray.append(touchRadius)
            
            if let previousItem = previousTraversedAtomItem {
                dict["DD.\(key).\(previousItem.key)"] = (endedAtom?.touchObject?.timestamp ?? 0.0) - (previousItem.ended?.touchObject?.timestamp ?? 0.0)
                dict["UD.\(key).\(previousItem.key)"] = (beginAtom?.touchObject?.timestamp ?? 0.0) - (previousItem.ended?.touchObject?.timestamp ?? 0.0)
            }
            previousTraversedAtomItem = AtomBeganAndEndedStruct(began: beginAtom, ended: endedAtom, allAtoms: Array(characterAtoms), key: key)
//
//            let charAtoms:[Atom] = mutableAtoms.filter({ $0.key == String(char) })
//            var firstCharAtoms:[Atom] = []
//            for atom in charAtoms {
//                firstCharAtoms.append(atom)
//                if atom.jsonTouch?["phase"] == "ended" { break }
//            }
//            mutableAtoms.removeAll(where: { atom in firstCharAtoms.contains(where: { $0.id == atom.id }) })
        }
        dict["AvH"] = holdTimeArray.reduce(0.0, +) / Double(holdTimeArray.count)
        dict["AvP"] = pressureArray.reduce(0.0, +) / Double(pressureArray.count)
        dict["AvA"] = touchRadiusArray.reduce(0.0, +) / Double(touchRadiusArray.count)
        dict["Subject"] = user ?? "NULL"
        guard let pass = pass else {
            print("pass is not found")
            return
        }
        self.db.collection(pass).addDocument(data: dict) { error in
            if error == nil {
                print("🔥successfullly pushed the processed data to firestore🔥")
                let _ = sendUnprocessedData()
            }
        }
        
        atoms = []
    }
    
    public func registerUser(completion handle:((_ responce: JSON?, _ error: String?) -> Void)?) {
        
        let json: JSON = ["device_id": deviceId]
        
        if let parameters: Parameters = json.dictionaryObject {
            let headers: HTTPHeaders = [
                "Content-Type": "application/json"
            ]
            
            AF.request("\(server)/registeruser",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding(options: []),
                headers: headers)
                .validate()
                .responseJSON { (response) in
                    
                    var json: JSON?
                    
                    switch response.result {
                    case .success(let value):
                        json = JSON(value)
                        print("JSON: \(json!)")
                    case .failure(let error):
                        print(error)
                    }
                    
                    if let _json = json {
                        if let userName = _json["username"].string,
                            let userPass = _json["textvalue"].string {
                                self.user = userName
                                self.pass = userPass
                                if let _handle = handle {
                                    _handle(_json, nil)
                                }
                        }
                    } else {
                        if let _handle = handle {
                            _handle(nil, "Server dead")
                        }
                    }
            }
        }
    }
    
    public func toleranceIdentityChecker(completion handle:((_ responce: JSON?, _ error: String?) -> Void)?) {
        print("Send [\(atoms.count)] atoms")
        
        var dataAtoms: [Any] = []
        for atom in atoms {
            dataAtoms.append(atom.json)
        }
        
        let json: JSON = ["user": user ?? "NULL",
                          "textValue": pass ?? "NULL",
                          "deviceID": deviceId,
                          "timestamp": Date().timeIntervalSince1970,
                          "model": UIDevice.modelName,
                          "os": UIDevice.current.systemVersion,
                          "items": dataAtoms]
        
        atoms = []
        
        //print(json.rawString(options: [.prettyPrinted]) ?? "empty")
        
        if let parameters: Parameters = json.dictionaryObject {
            let headers: HTTPHeaders = [
                "Content-Type": "application/json"
            ]
            print("\(server)/tolerancecheckerfake")
            AF.request("\(server)/tolerancecheckerfake",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding(options: []),
                headers: headers)
                .validate()
                .responseJSON { (response) in
                    
                    var json: JSON?
                    
                    switch response.result {
                    case .success(let value):
                        json = JSON(value)
                        print("JSON: \(json!)")
                    case .failure(let error):
                        print(error)
                    }
                    
                    guard let _ = handle else { return }
                    if let _json = json {
                        if let _ = _json["fraud_alert"].string,
                            let _ = _json["session_id"].string {
                            handle!(json, nil)
                        } else {
                            if let errTxt = _json["error"].string {
                                handle!(nil, errTxt)
                            }
                        }
                    } else {
                        handle!(json, "Ошибка формата данных")
                    }
                    
            }
        }
    }
    
}

public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}
