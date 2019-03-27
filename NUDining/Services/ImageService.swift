//
//  ImageService.swift
//  NUDining
//
//  Created by Nils Backe on 12/29/18.
//  Copyright © 2018 Plus Hundred. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Firebase

struct ImageService {
    
    static let db = Firestore.firestore()
    
    public static func imageFromUrl(url: URL, completion: @escaping (UIImage?) -> Void) {
        let request = NSURLRequest(url: url)
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) {
            (response: URLResponse?, data: Data?, error: Error?) -> Void in
            if let imageData = data as Data? {
                return completion(UIImage(data: imageData))
            } else {
                return completion(nil)
            }
        }
    }
    
//    public static func getImageURLFromFirestore(name: String, completion: @escaping (URL?) -> Void) {
//        let ref = db.collection("foods").whereField("name", isEqualTo: name)
//        ref.getDocuments { (querySnapshot, error) in
//            if let error = error {
//                print("error: \(error)")
//                return completion(nil)
//            }
//            if let snapshot = querySnapshot {
//                if snapshot.documents.count != 0 {
//                    let data = snapshot.documents[0].data()
//                    return completion(URL(string: data["imageURL"] as! String))
//                } else {
//                    return completion(nil)
//                }
//            } else {
//                return completion(nil)
//            }
//        }
//    }
    
    // make sure that mutation works this way
    public static func setAllImages(mealStations doubleList: [[MealStation]?], completion: @escaping () -> ()) {
        self.getAllFoodImageURLs { dictionary in
            for mealStationsOpt in doubleList {
                if let mealStations = mealStationsOpt {
                    for mealStation in mealStations {
                        for item in mealStation.items {
                            if dictionary.contains(where: {$0.key == item.name}) {
                                item.imageURL = dictionary[item.name]
                            }
                        }
                    }
                }
            }
            return completion()
        }
    }
    
    // returns [ foodName : url ]
    private static func getAllFoodImageURLs(completion: @escaping ([String : String]) -> ()) {
        var dict: [String : String] = [:]
        db.collection("foods").getDocuments { (querySnapshot, error) in
            if let err = error {
                print("Error fetching foods collection: \(err)")
                return completion(dict)
            } else {
                for doc in querySnapshot!.documents {
                    var data = doc.data()
                    dict[data["name"] as! String] = data["imageURL"] as? String
                }
                return completion(dict)
            }
        }
        
    }
    
    public static func fetchImageURLFromBing(query: String, completion: @escaping (URL?) -> ()) {
        let url = "https://api.cognitive.microsoft.com/bing/v7.0/images/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&count=1"
        
        let headers = ["Ocp-Apim-Subscription-Key": "43b88d14107d40ee9cc8cbd4a1cb7967"]
        
        Alamofire.request(url, headers: headers).responseJSON { response in
            let json: JSON = JSON(response.result.value!)
            let urlStr = json["value"][0]["contentUrl"].string
            guard let _urlStr = urlStr else {
                return completion(nil)
            }
            return completion(URL(string: _urlStr))
        }
    }
    
    // returns an optional error
    public static func saveImageURLToFirebase(name: String, url: String, completion: @escaping (String?) -> ()) {
        let data = ["name":name,
                    "imageURL":url]
        db.collection("foods").document(name).setData(data, merge: true) { err in
            if let err = err {
                print("Error adding document: \(err)")
                return completion(err.localizedDescription)
            } else {
                print("Document added")
                return completion(nil)
            }
        }
    }
}
