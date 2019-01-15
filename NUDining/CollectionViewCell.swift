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
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var wholeStackView: UIStackView!
    @IBOutlet weak var textStackView: UIStackView!
    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 10.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        view.clipsToBounds = true
//        view.layer.cornerRadius = 10
//        view.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
//        view.clipsToBounds = true
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOffset = CGSize(width: 5, height: 5)
//        view.layer.shadowRadius = 5
//        view.layer.shadowOpacity = 0.5
        view.backgroundColor = UIColor.clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.layer.shadowOpacity = 0.7
        view.layer.shadowRadius = 4.0
        
        let borderView = UIView()
        borderView.frame = view.bounds
        borderView.layer.cornerRadius = 10
        borderView.layer.masksToBounds = true
        view.addSubview(borderView)
    }
}
