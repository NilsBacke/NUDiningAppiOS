//
//  LoadingScreen.swift
//  NUDining
//
//  Created by Nils Backe on 3/3/19.
//  Copyright © 2019 Plus Hundred. All rights reserved.
//

import Foundation
import UIKit

class LoadingScreenViewController: UIViewController {
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    var totalProgress: Float = 0
    let divisor: Float = 9.0
    
    override func viewDidLoad() {
        // any location and time of day
        self.progressBar.progress = 0.0
        MenuService.getSpecificMenu(location: .Steast, timeOfDay: .Breakfast, progressCompletion: { progress in
            if progress >= 1.0 {
                self.totalProgress += Float(progress)
            }
            self.progressBar.progress = self.totalProgress / self.divisor
            
            print("totalProgress: \(self.totalProgress)")
            if self.totalProgress >= self.divisor {
                let tabBarVC = MainTabBarController.storyboardInstance()!
                self.present(tabBarVC, animated: true, completion: nil)
            }
        }) { menu in
            
        }
        MenuService.getSpecificMenu(location: .IV, timeOfDay: .Breakfast, progressCompletion: { progress in
            if progress >= 1.0 {
                self.totalProgress += Float(progress)
            }
            self.progressBar.progress = self.totalProgress / self.divisor
            
            print("totalProgress: \(self.totalProgress)")
            if self.totalProgress >= self.divisor {
                let tabBarVC = MainTabBarController.storyboardInstance()!
                self.present(tabBarVC, animated: true, completion: nil)
            }
        }) { menu in
            
        }
        MenuService.getSpecificMenu(location: .Stwest, timeOfDay: .Breakfast, progressCompletion: { progress in
            if progress >= 1.0 {
                self.totalProgress += Float(progress)
            }
            self.progressBar.progress = self.totalProgress / self.divisor
            
            print("totalProgress: \(self.totalProgress)")
            if self.totalProgress >= self.divisor {
                let tabBarVC = MainTabBarController.storyboardInstance()!
                self.present(tabBarVC, animated: true, completion: nil)
            }
        }) { menu in
            
        }
    }
}
