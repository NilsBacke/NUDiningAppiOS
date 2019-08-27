//
//  IceCreamTableViewCell.swift
//  NUDining
//
//  Created by Nils Backe on 4/9/19.
//  Copyright © 2019 Plus Hundred. All rights reserved.
//

import UIKit

class IceCreamTableViewCell: UITableViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var flavorOne: UILabel!
    @IBOutlet weak var flavorTwo: UILabel!
    
    override func layoutSubviews() {
        // Set the width of the cell
        self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.size.width - 40, height: self.bounds.size.height)
        super.layoutSubviews()
    }
}
