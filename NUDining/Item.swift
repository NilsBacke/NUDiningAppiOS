//
//  Item.swift
//  NUDining
//
//  Created by Nils Backe on 1/4/19.
//  Copyright © 2019 Plus Hundred. All rights reserved.
//

import Foundation
import UIKit

class Item {
    let name: String
    let ingredients: String
    var imageURL: String?
    var image: UIImage?
    
    init(name: String, ingredients: String, imageURL: String?) {
        self.name = name
        self.ingredients = ingredients
        self.imageURL = imageURL
    }
}
