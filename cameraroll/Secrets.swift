//
//  Secrets.swift
//  cameraroll
//
//  Created by Nate Parrott on 2/28/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation

class Secrets {
    static let shared = Secrets()
    init() {
        let path = Bundle.main.url(forResource: "Secrets", withExtension: "json")!
        let data = try! Data(contentsOf: path)
        let dict = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
        googleApiKey = dict["google_api_key"] as! String
    }
    let googleApiKey: String
}
