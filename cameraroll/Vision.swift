//
//  Vision.swift
//  cameraroll
//
//  Created by Nate Parrott on 2/28/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation
import UIKit

class VisionRequest {
    init(image: UIImage) {
        self.image = image
    }
    let image: UIImage
    
    func run(callback: @escaping (((String, UIColor)?) -> ())) {
        var components = URLComponents(string: "https://vision.googleapis.com/v1/images:annotate")!
        components.queryItems = [URLQueryItem(name: "key", value: Secrets.shared.googleApiKey)]
        
        let imageDict: [String: Any] = ["content": UIImagePNGRepresentation(image)!.base64EncodedString()]
        let features: [[String: Any]] = [
            ["type": "LABEL_DETECTION"],
            ["type": "IMAGE_PROPERTIES"],
            // ["type": "LOGO_DETECTION"],
            ["type": "FACE_DETECTION"]
            // ["type": "LANDMARK_DETECTION"]
        ]
        let annotationReq: [String: Any] = ["image": imageDict, "features": features]
        let bodyJson: [String: Any] = ["requests": [annotationReq]]
        
        var req = URLRequest(url: components.url!)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "POST"
        req.httpBody = try! JSONSerialization.data(withJSONObject: bodyJson, options: [])
        
        URLSession.shared.dataTask(with: req) { (dataOpt, responseOpt, _) in
            if let data = dataOpt,
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
                let str = String(data: data, encoding: .utf8)!
                print(str)
                
                if let responses = json["responses"] as? [[String: Any]],
                    responses.count > 0 {
                    let response = responses[0]
                    let color = self.getColorFromResponse(resp: response)
                    let labels = self.getLabelsFromResponse(resp: response)
                    let emotions = self.getEmotionsFromResponse(resp: response)
                    print("Color: \(color)")
                    print("Labels: \(labels)")
                    print("Emotions: \(emotions)")
                    let text = (labels + emotions).shuffled().joined(separator: " // ").uppercased()
                    callback((text, color))
                } else {
                    print("Didn't expect this JSON")
                    callback(nil)
                }
            } else {
                print("No response from vision api")
                callback(nil)
            }
        }.resume()
    }
    
    func getLabelsFromResponse(resp: [String: Any]) -> [String] {
        if let labels = resp["labelAnnotations"] as? [[String: Any]] {
            let labelStrings = labels.map({ $0["description"] as! String })
            return labelStrings
        } else {
            return []
        }
    }
    
    func getColorFromResponse(resp: [String: Any]) -> UIColor {
        if let imageProperties = resp["imagePropertiesAnnotation"] as? [String: Any],
            let dominantColors = imageProperties["dominantColors"] as? [String: Any],
            let colors = dominantColors["colors"] as? [[String: Any]],
            colors.count > 0 {
            let topColorDict = colors[0]["color"] as! [String: Double]
            let r = CGFloat(topColorDict["red"]!)
            let g = CGFloat(topColorDict["red"]!)
            let b = CGFloat(topColorDict["red"]!)
            
            return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
        } else {
            return UIColor.purple
        }
    }
    
    func getEmotionsFromResponse(resp: [String: Any]) -> [String] {
        var emotions = [String]()
        if let faces = resp["faceAnnotations"] as? [[String: Any]] {
            let emotionDict = ["joyLikelihood": "happy", "sorrowLikelihood": "sorrow", "surpriseLikelihood": "surprised", "angerLikelihood": "angry"]
            for face in faces {
                for (key, emotionName) in emotionDict {
                    let val = face[key] as! String
                    if val == "LIKELY" || val == "VERY_LIKELY" {
                        emotions.append(emotionName)
                    }
                }
            }
        }
        return emotions
    }
}
