//
//  TabBarController.swift
//  NUDining
//
//  Created by Nils Backe on 12/22/18.
//  Copyright © 2018 Plus Hundred. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MainTabBarController : UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForNotifications()
        self.getDeviceID { id in
            if let deviceID = id {
                PreferredFoodService.writeDeviceID(deviceId: deviceID)
            }
        }
    }
    
    private func getDeviceID(completion: @escaping (String?) -> Void) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
                return completion(nil)
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                return completion(result.token)
            }
        }
    }
    
    private func registerForNotifications() {
        
    }
}
