//
//  ViewController.swift
//  cameraroll
//
//  Created by Nate Parrott on 2/27/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateLogItems), name: LogManager.DidLogNotification, object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            LogManager.Shared.log(str: "Launched app")
            
//            let img = PicMaker.makePic(color: UIColor.green, text: "wow what the fuck")
//            
//            Tweeter.shared.tweet(image: img) { (_) in
//                
//            }
            
//            PhotoGrabber.Shared.grabRecentPhoto(callback: { (res) in
//                if let r = res {
//                    let img = r.img
//                    VisionRequest(image: img).run(callback: { (_) in
//                        
//                    })
//                }
//            })
//            Tweeter.shared.tweet(str: "test", callback: { (success) in
//                print("Success: \(success)")
//            })
        }
        self.logItems = LogManager.Shared.items.reversed()
        
        updateAccountPickerUI()
    }
    
    func updateAccountPickerUI() {
        Tweeter.shared.requestAccess { (success) in
            DispatchQueue.main.async {
                if success {
                    var title = "Select account..."
                    if let selectedAccount = UserDefaults.standard.string(forKey: "SelectedAccount") {
                        title = selectedAccount
                    }
                    let btn = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(ViewController.pickAccount))
                    self.navigationItem.leftBarButtonItem = btn
                }
            }
        }
    }
    
    func pickAccount(sender: UIBarButtonItem!) {
        if Tweeter.shared.hasAccess {
            let picker = UIAlertController(title: "Pick a Twitter account", message: nil, preferredStyle: .actionSheet)
            for account in Tweeter.shared.accounts {
                picker.addAction(UIAlertAction(title: account.username, style: .default, handler: { (_) in
                    UserDefaults.standard.setValue(account.username, forKey: "SelectedAccount")
                    self.updateAccountPickerUI()
                }))
            }
            picker.addAction(UIAlertAction(title: "Don't tweet from any account", style: .destructive, handler: { (_) in
                UserDefaults.standard.setValue(nil, forKey: "SelectedAccount")
                self.updateAccountPickerUI()
            }))
            picker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    // MARK: Log items
    func updateLogItems(notif: Notification) {
        DispatchQueue.main.async {
            self.logItems = LogManager.Shared.items.reversed()
        }
    }
    
    var logItems = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = logItems[indexPath.row]
        return cell
    }
}

