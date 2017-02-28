//
//  LogManager.swift
//  cameraroll
//
//  Created by Nate Parrott on 2/27/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation

class LogManager {
    static let Shared = LogManager()
    
    static let DidLogNotification = NSNotification.Name("LogManagerDidLogNotification")
    
    init() {
        if let data = try? Data(contentsOf: savePath),
            let items = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String] {
            self.items = items
        }
    }
    
    var items = [String]()
    
    let savePath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!).appendingPathComponent("log.json")
    
    func log(str: String) {
        let fullStr = "\(Date()): \(str)"
        items.append(fullStr)
        NotificationCenter.default.post(name: LogManager.DidLogNotification, object: nil)
        print("Logging: \(str)")
        save()
    }
    
    func save() {
        var itemsToSave = items
        let maxCount = 100
        if itemsToSave.count > maxCount {
            itemsToSave = Array(itemsToSave[(itemsToSave.count - maxCount)..<itemsToSave.count])
        }
        let data = try! JSONSerialization.data(withJSONObject: items, options: [])
        try! data.write(to: savePath)
    }
}
