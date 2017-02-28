//
//  PhotoGrabber.swift
//  cameraroll
//
//  Created by Nate Parrott on 2/27/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation
import Photos
import UIKit

class PhotoGrabber {
    static let Shared = PhotoGrabber()
    
    func grabRecentPhoto(callback: @escaping (((img: UIImage, date: Date)?) -> ())) {
        DispatchQueue.global(qos: .background).async {
            PHPhotoLibrary.requestAuthorization { (status) in
                print("Photos authorization status: \(status)")
                if status == PHAuthorizationStatus.authorized {
                    let options = PHFetchOptions()
                    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    options.fetchLimit = 1
                    if let result = PHAsset.fetchAssets(with: options).lastObject {
                        let options = PHImageRequestOptions()
                        options.isSynchronous = true
                        PHImageManager.default().requestImage(for: result, targetSize: CGSize(width: 500, height: 500)
                            , contentMode: PHImageContentMode.aspectFill, options: options, resultHandler: { (imageOpt, _) in
                                if let img = imageOpt, let date = result.creationDate {
                                    callback((img: img.resizedWithMaxDimension(600), date: date))
                                } else {
                                    callback(nil)
                                }
                        })
                    } else {
                        callback(nil)
                    }
                } else {
                    callback(nil)
                }
            }
        }
    }
}
