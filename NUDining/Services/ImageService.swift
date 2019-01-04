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

struct ImageService {
    
    public static func getImageFromKeyword(q: String, completion: @escaping (UIImage?) -> Void) {
        var query = q
        
        if query == "Orange" {
            query = "Orange Fruit"
        }
        
        let key = "AIzaSyDJbKdxDComCtL6llz1Nyu2IUpy1YShiGE"
        let cx = "005953852519046923142%3Azj49gwvnpa8"
        let num = 1
        let start = 1
        let imgSize = "medium"
        let searchType = "image"
        
        let encodedQuery = q.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let url = "https://www.googleapis.com/customsearch/v1?q=\(encodedQuery)&key=\(key)&cx=\(cx)&num=\(num)&start=\(start)&imgSize=\(imgSize)&searchType=\(searchType)"
        
        Alamofire.request(url).responseJSON { response in
            if response.result.isSuccess {
                print("Success")
                let json: JSON = JSON(response.result.value!)
                if let imageURL: String = json["items"][0]["link"].string {
                    print("imageURL: \(imageURL)")
                    self.imageFromUrl(urlString: imageURL, completion: { img in
                        return completion(img)
                    })
                } else {
                    return completion(nil)
                }
            } else {
                print("Failure")
                return completion(nil)
            }
        }
    }
    
    private static func imageFromUrl(urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(url: url as URL)
            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) {
                (response: URLResponse?, data: Data?, error: Error?) -> Void in
                if let imageData = data as Data? {
                    return completion(UIImage(data: imageData))
                } else {
                    return completion(nil)
                }
            }
        }
    }
}
