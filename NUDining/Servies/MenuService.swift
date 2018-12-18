//
//  MenuService.swift
//  NUDining
//
//  Created by Nils Backe on 12/17/18.
//  Copyright © 2018 Plus Hundred. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct MenuService {
    
    private static func getURL(location: Location) -> String {
        return "https://api.dineoncampus.com/v1/location/menu?site_id=5751fd2b90975b60e048929a&location_id=" + self.getLocationID(from: location) + "&platform=0&date=2018-12-17";
    }
    
    static func getAllMenus() {
        
    }
    
    static func getLocationID(from location: Location) -> String {
        switch location {
        case .IV:
            return "586d17503191a27120e60dec"
        case .Steast:
            return "586d05e4ee596f6e6c04b527"
        case .Stwest:
            return "5b9bd1c41178e90d4774210e"
        }
    }
}
