//
//  SubMenu.swift
//  NUDining
//
//  Created by Nils Backe on 12/17/18.
//  Copyright © 2018 Plus Hundred. All rights reserved.
//

import Foundation

class MealStation {
    let title: String
    var items: [Item] // (Name, Ingredients)
    
    init(title: String, items: [Item]) {
        self.title = title
        self.items = items
    }
}
