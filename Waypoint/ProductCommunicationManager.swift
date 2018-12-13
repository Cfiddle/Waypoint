//
//  ProductCommunicationManager.swift
//  Waypoint
//
//  Created by Charles Fiedler on 12/12/18.
//  Copyright © 2018 Charles Fiedler. All rights reserved.
//

import DJISDK

class ProductCommunicationManager: NSObject {
    
    func registerWithSDK() {
        DJISDKManager.registerApp(with: self)
    }
}

extension ProductCommunicationManager : DJISDKManagerDelegate {
    
    public func appRegisteredWithError(_ error: Error?) {
        if error != nil {
        } else {
            if DJISDKManager.startConnectionToProduct() {
                print("Sucessfully connected to product")
            } else {
                print("Failed to connect to product")
            }
        }
    }

    func productConnected(_ product: DJIBaseProduct?) {
        print("CONNECTED!")
    }

    func productDisconnected() {
        
    }

    func componentConnected(withKey key: String?, andIndex index: Int) {
        
    }

    func componentDisconnected(withKey key: String?, andIndex index: Int) {
        
    }

    func showAlertWithTitle(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}

