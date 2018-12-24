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
        FoodService.saveDeviceID()
    }
    
    private func registerForNotifications() {
        
    }
}
