//
//  PicMaker.swift
//  cameraroll
//
//  Created by Nate Parrott on 2/28/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import UIKit
import CoreImage

class PicMaker {
    static func makePic(color: UIColor, text: String) -> UIImage {
        let (h,_,v,a) = color.hsva
        let bgColor = UIColor(hue: h, saturation: 0.2, brightness: v, alpha: a)
        let fgColor = UIColor(hue: h, saturation: 0.3, brightness: v > 0.5 ? 0.1 : 0.9, alpha: 0.7)
        let size = CGSize(width: 400, height: 300)
        return UIGraphicsImageRenderer(size: size).image(actions: { (ctx) in
            bgColor.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            paraStyle.alignment = .center
            let font = UIFont(name: "Arial-ItalicMT", size: 20)!
            var frame = CGRect(x: 10, y: 10, width: size.width - 20, height: size.height - 20)
            let attrStr = NSAttributedString(string: text, attributes: [NSParagraphStyleAttributeName: paraStyle, NSForegroundColorAttributeName: fgColor, NSFontAttributeName: font]).resizeToFit(inside: frame.size)!
            let textSize = attrStr.boundingRect(with: frame.size, options: .usesLineFragmentOrigin, context: nil)
            frame.origin.y = (size.height - textSize.height)/2
            attrStr.draw(in: frame)
        })
    }
    
    static func makePic(image: UIImage, text: String) -> UIImage {
        let fgColor = UIColor(hue: 0, saturation: 0, brightness: 0.1, alpha: 0.5)
        
        let size = CGSize(width: 400, height: 250)
        
        let imageScale = max(size.width / image.size.width, size.height / image.size.height)
        let imageSize = CGSize(width: image.size.width * imageScale, height: image.size.height * imageScale)
        let imageFrame = CGRect(x: (size.width - imageSize.width)/2, y: (size.height - imageSize.height)/2, width: imageSize.width, height: imageSize.height)
        
        return UIGraphicsImageRenderer(size: size).image(actions: { (ctx) in
            UIColor.white.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            image.draw(in: imageFrame)
            
            let paraStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
            paraStyle.alignment = .center
            let font = UIFont(name: "Arial-ItalicMT", size: 20)!
            var frame = CGRect(x: 10, y: 10, width: size.width - 20, height: size.height - 20)
            let attrStr = NSAttributedString(string: text, attributes: [NSParagraphStyleAttributeName: paraStyle, NSForegroundColorAttributeName: fgColor, NSFontAttributeName: font]).resizeToFit(inside: frame.size)!
            let textSize = attrStr.boundingRect(with: frame.size, options: .usesLineFragmentOrigin, context: nil)
            frame.origin.y = (size.height - textSize.height)/2
            attrStr.draw(in: frame)
        })
    }
    
    static func filterImage(image: UIImage) -> UIImage {
        let ciImage = CIImage(image: image)!
        let brighten = CIFilter(name: "CIColorControls", withInputParameters: ["inputBrightness": 0.4, "inputImage": ciImage])!
        let pixellate = CIFilter(name: "CIPixellate", withInputParameters: ["inputImage": brighten.outputImage!, "inputScale": 120.0])!
        return UIImage(ciImage: pixellate.outputImage!)
    }
}
