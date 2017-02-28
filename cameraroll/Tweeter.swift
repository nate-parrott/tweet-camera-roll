//
//  Tweeter.swift
//  cameraroll
//
//  Created by Nate Parrott on 2/28/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import Foundation
import Accounts
import Social

class Tweeter {
    static let shared = Tweeter()
    
    let store = ACAccountStore()
    var hasAccess = false
    
    func requestAccess(callback: @escaping ((Bool) -> ())) {
        if hasAccess {
            callback(true)
            return
        }
        if let twitterType = store.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter) {
            store.requestAccessToAccounts(with: twitterType, options: nil, completion: { (success, errOpt) in
                if success {
                    self.hasAccess = true
                    callback(true)
                } else {
                    print("Error: \(errOpt)")
                    callback(false)
                }
            })
        } else {
            print("No account type for twitter")
            callback(false)
        }
    }
    
    var accounts: [ACAccount] {
        get {
            if hasAccess {
                if let twitterType = store.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter) {
                    return store.accounts(with: twitterType) as! [ACAccount]
                }
            }
            return []
        }
    }
    
    func tweet(str: String, callback: @escaping (Bool) -> ()) {
        if let account = preferredAccount {
            let url = URL(string: "https://api.twitter.com/1/statuses/update.json")!
            let req = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, url: url, parameters: ["status": str.truncateForTweet])!
            req.account = account
            req.perform(handler: { (_, resp, _) in
                print("Got response code: \(resp?.statusCode)")
                callback((resp?.statusCode ?? 0) == 200)
            })
        } else {
            print("Tried to tweet, but don't have an account")
            callback(false)
        }
    }
    
    func tweet(image: UIImage, callback: @escaping (Bool) -> ()) {
        if let account = preferredAccount {
            let url = URL(string: "https://api.twitter.com/1/statuses/update_with_media.json")!
            let req = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, url: url, parameters: nil)!
            req.addMultipartData(UIImagePNGRepresentation(image), withName: "media[]", type: "multipart/form-data", filename: "image.png")
            req.account = account
            req.perform(handler: { (_, resp, _) in
                print("Got response code: \(resp?.statusCode)")
                callback((resp?.statusCode ?? 0) == 200)
            })
        } else {
            print("Tried to tweet, but don't have an account")
            callback(false)
        }
    }
    
    var preferredAccount: ACAccount? {
        get {
            if let name = UserDefaults.standard.string(forKey: "SelectedAccount") {
                return accounts.filter({ $0.username == name }).first
            } else {
                return nil
            }
        }
    }
}

extension String {
    var truncateForTweet: String {
        let index = self.index(startIndex, offsetBy: 140, limitedBy: endIndex) ?? endIndex
        return self.substring(to: index)
    }
}
