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
    
    public static func getImageURLFromFirestore(name: String, completion: @escaping (URL?) -> Void) {
        let ref = db.collection("foods").whereField("name", isEqualTo: name)
        ref.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("error: \(error)")
                return completion(nil)
            }
            if let snapshot = querySnapshot {
                let data = snapshot.documents[0].data()
                return completion(URL(string: data["imageURL"] as! String))
            } else {
                return completion(nil)
            }
        }
    }
}
