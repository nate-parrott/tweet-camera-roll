//
//  UIImage+Base64.swift
//  cameraroll
//
//  Created by Nate Parrott on 2/28/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import UIKit

extension UIImage {
    var base64: String {
        get {
            let data = UIImagePNGRepresentation(self)!
            return data.base64EncodedString()
        }
    }
}
