//
//  ViewController.swift
//  Waypoint
//
//  Created by Charles Fiedler on 12/7/18.
//  Copyright © 2018 Charles Fiedler. All rights reserved.
//

import UIKit
import DJISDK

class ViewController: UIViewController, DJISDKManagerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.registerApp()
    }

    func registerApp() {
        DJISDKManager.registerApp(with: self)
    }
    
    func appRegisteredWithError(_ error: Error?) {
        var message = "App Registered Successfully!"
        if error != nil {
            message = "App Failed to Register! Please enter your App Key in the plist file and check the network."
        }
        showAlertWithTitle(title: "Register App", message: message)
    }
    
    func showAlertWithTitle(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

