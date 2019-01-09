//
//  CustomCollectionViewCell.swift
//  NUDining
//
//  Created by Nils Backe on 1/1/19.
//  Copyright © 2019 Plus Hundred. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion

class CollectionViewCell : UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    let motionManager = CMMotionManager()
    
    override func layoutSubviews() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.02
            motionManager.startDeviceMotionUpdates(to: .main, withHandler: { (motion, error) in
                if let motion = motion {
                    let pitch = motion.attitude.pitch * 10 // x-axis
                    let roll = motion.attitude.roll * 10 // y-axis
//                    self.applyShadow(width: CGFloat(roll), height: CGFloat(pitch))
                }
            })
        }
    }
}
