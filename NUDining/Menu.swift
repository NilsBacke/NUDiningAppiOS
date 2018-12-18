//
//  Menu.swift
//  NUDining
//
//  Created by Nils Backe on 12/16/18.
//  Copyright © 2018 Plus Hundred. All rights reserved.
//

import Foundation

enum Location {
    case Steast
    case Stwest
    case IV
}

enum TimeOfDay {
    case Breakfast
    case Lunch
    case Dinner
}

struct Menu {
    let location: Location
    let locationID: String
    let time: TimeOfDay
    let mealStations: [MealStation]
    
    init(location: Location, time: TimeOfDay) {
        self.location = location
        self.time = time
        self.locationID = MenuService.getLocationID(from: location)
        self.mealStations = []
    }
}
