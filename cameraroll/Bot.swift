//
//  Bot.swift
//  cameraroll
//
//  Created by Nate Parrott on 2/28/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class Bot : NSObject, CLLocationManagerDelegate {
    static let Shared = Bot()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        Tweeter.shared.requestAccess { (success) in
            if success {
                print("got twitter access")
            } else {
                print("no twitter access")
            }
        }
        locationManager.allowsBackgroundLocationUpdates = true 
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            locationManager.startMonitoringSignificantLocationChanges()
        default: ()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if UIApplication.shared.applicationState == UIApplicationState.background {
            LogManager.Shared.log(str: "Received location update while in background")
        }
        refresh()
    }
    
    let locationManager = CLLocationManager()
    
    var lastRefreshCall: TimeInterval = 0
    func refresh() {
        if Date.timeIntervalSinceReferenceDate - lastRefreshCall < 10 {
            return
        }
        lastRefreshCall = Date.timeIntervalSinceReferenceDate
        
        let fail = {
            (error: String) -> () in
            LogManager.Shared.log(str: "\(error)")
        }
        
        PhotoGrabber.Shared.grabRecentPhoto { (resultOpt) in
            if let result = resultOpt {
                let lastPicDate = UserDefaults.standard.double(forKey: "lastPicDate")
                let thisPicDate = result.date.timeIntervalSinceReferenceDate
                if thisPicDate > lastPicDate {
                    LogManager.Shared.log(str: "found a new photo with date: \(result.date)")
                    VisionRequest(image: result.img).run(callback: { (visionResult) in
                        if let (text, color) = visionResult {
                            let bgImage = PicMaker.filterImage(image: result.img)
                            let tweetImage = PicMaker.makePic(image: bgImage, text: text)
                            LogManager.Shared.log(str: "Request to vision API succeeded")
                            Tweeter.shared.tweet(image: tweetImage, callback: { (success) in
                                if success {
                                    LogManager.Shared.log(str: "Tweeted: \(text)")
                                    UserDefaults.standard.set(thisPicDate, forKey: "lastPicDate")
                                } else {
                                    fail("failed to tweet")
                                }
                            })
                        } else {
                            fail("Request to vision API failed")
                        }
                    })
                } else {
                    fail("No recent photo")
                }
            } else {
                fail("Didnt find any photos")
            }
        }
    }
}
