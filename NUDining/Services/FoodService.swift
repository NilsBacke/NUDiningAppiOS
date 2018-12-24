//
//  PreferredFoodService.swift
//  NUDining
//
//  Created by Nils Backe on 12/22/18.
//  Copyright © 2018 Plus Hundred. All rights reserved.
//

import Foundation
import Firebase

struct FoodService {
    static let db = Firestore.firestore()
    
    static var deviceID: String?
    
    // change to be run at startup in the background, with a singleton
    public static func getAllFoods(completion: @escaping ([String]) -> Void) {
        db.collection("foods").getDocuments { (querySnapshot, err) in
            var foods = getDataFromSnapshot(querySnapshot, err: err, key: "name")
            for i in 0 ..< foods.count {
                foods[i] = foods[i].trim()
            }
            foods.sort()
            return completion(foods)
        }
    }
    
    public static func getPreferredFoods(completion: @escaping ([String]) -> Void) {
        getDeviceID { id in
            guard let deviceID = id else {
                fatalError("device ID is nil")
            }
            db.collection("devices").document(deviceID).collection("preferredFoods").getDocuments(completion: { (querySnapshot, err) in
                return completion(getDataFromSnapshot(querySnapshot, err: err, key: "food"))
            })
        }
    }
    
    private static func getDataFromSnapshot(_ snapshot: QuerySnapshot?, err: Error?, key: String) -> [String] {
        if err != nil {
            print("Could not get preferred foods")
            return []
        } else {
            var foods: [String] = []
            for doc in snapshot!.documents {
                foods.append(doc.data()[key] as! String)
            }
            return foods
        }
    }
    
    public static func addPreferredFood(_ food: String, completion: @escaping (Bool) -> Void) {
        getDeviceID { id in
            guard let deviceID = id else {
                fatalError("device ID is nil")
            }
            db.collection("devices").document(deviceID).collection("preferredFoods").document(food).setData(["food" : food]) { err in
                if err != nil {
                    return completion(false)
                } else {
                    return completion(true)
                }
            }
        }
    }
    
    public static func removeReferredFood(_ food: String, completion: @escaping (Bool) -> Void) {
        getDeviceID { id in
            guard let deviceID = id else {
                fatalError("device ID is nil")
            }
            db.collection("devices").document(deviceID).collection("preferredFoods").document(food).delete() { err in
                if err != nil {
                    return completion(false)
                } else {
                    return completion(true)
                }
            }
        }
    }
    
    public static func saveDeviceID() {
        getDeviceID { id in
            guard let _id = id else {
                fatalError("device ID is nil")
            }
            db.collection("devices").document(_id).setData(["deviceID" : _id])
        }
    }
    
    private static func getDeviceID(completion: @escaping (String?) -> Void) {
        if let id = self.deviceID {
            return completion(id)
        } else {
            fetchDeviceID { optID in
                guard let _id = optID else {
                    return completion(nil)
                }
                self.deviceID = _id
                // save deviceID
                return completion(self.deviceID)
            }
        }
    }
    
    private static func fetchDeviceID(completion: @escaping (String?) -> Void) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
                return completion(nil)
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                return completion(result.token)
            }
        }
    }
}

extension String
{
    func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}
