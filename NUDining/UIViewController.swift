//
//  UIViewController.swift
//  NUDining
//
//  Created by Nils Backe on 3/3/19.
//  Copyright © 2019 Plus Hundred. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func presentAlert(title: String = "Error", errorMessage: String?) {
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        self.present(alert, animated: true)
    }
}
