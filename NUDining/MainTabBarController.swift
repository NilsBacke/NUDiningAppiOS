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
        FoodService.saveDeviceID()
        self.tabBar.tintColor = UIColor.red
        
        let items = tabBar.items!
        
        for idx in 0..<items.count {
            items[idx].title = LABELS[idx]
            items[idx].tag = idx
        }
    }
    
    static func storyboardInstance() -> MainTabBarController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? MainTabBarController
    }
    
}
