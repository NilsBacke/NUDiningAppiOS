//
//  PreferredFoodService.swift
//  NUDining
//
//  Created by Nils Backe on 12/22/18.
//  Copyright © 2018 Plus Hundred. All rights reserved.
//

import Foundation
import Firebase



struct PreferredFoodService {
    static let db = Firestore.firestore()
    
    static func writeDeviceID(deviceId: String) {
        db.collection("devices").document(deviceId).setData(["deviceID" : deviceId])
    }
    
    // savePreferredFoods
}
