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
    
    let LABELS = ["Steast", "IV", "Stwest", "Notifications"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerForNotifications()
        self.tabBar.tintColor = UIColor.red
        
        let items = tabBar.items!
        
        for idx in 0..<items.count {
            items[idx].title = LABELS[idx]
            items[idx].tag = idx
        }
    }
    
    private func registerForNotifications() {
        
    }
    
}
