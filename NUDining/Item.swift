//
//  Item.swift
//  NUDining
//
//  Created by Nils Backe on 1/4/19.
//  Copyright © 2019 Plus Hundred. All rights reserved.
//

import Foundation

struct Item {
    let name: String
    let ingredients: String
    
    init(name: String, ingredients: String) {
        self.name = name
        self.ingredients = ingredients
    }
}
