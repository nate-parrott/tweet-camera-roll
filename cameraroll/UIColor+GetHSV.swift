//
//  UIColor+GetHSV.swift
//  cameraroll
//
//  Created by Nate Parrott on 2/28/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import UIKit

extension UIColor {
    var hsva: (CGFloat, CGFloat, CGFloat, CGFloat) {
        get {
            var h: CGFloat = 0
            var s: CGFloat = 0
            var v: CGFloat = 0
            var a: CGFloat = 0
            getHue(&h, saturation: &s, brightness: &v, alpha: &a)
            return (h,s,v,a)
        }
    }
}
