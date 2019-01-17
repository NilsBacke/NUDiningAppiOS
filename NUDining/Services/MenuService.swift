//
//  MenuService.swift
//  NUDining
//
//  Created by Nils Backe on 12/17/18.
//  Copyright © 2018 Plus Hundred. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias MenuDict = [Location : [TimeOfDay : Menu]]

let DEBUG: Bool = true

struct MenuService {
    
    private static let locations: [Location] = [Location.Steast, Location.IV, Location.Stwest]
    private static let timesOfDay: [TimeOfDay] = [TimeOfDay.Breakfast, TimeOfDay.Lunch, TimeOfDay.Dinner]
    
    // get today's date in String format: YYYY-MM-DD
    private static var todaysDate: String {
        if DEBUG == true {
            return "2019-01-15"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
        let date = Date()
        return dateFormatter.string(from: date)
    }
    
    // [ Location : [ TimeOfDay : Menu ]]
    // private variable, used to hold the menus locally instead of having to perform an API request everytime to retrieve them
    private static var menus: MenuDict?
    
    // returns the menu of a specific place and time
    // if it does not exist, return nil
    // nil cases:
    // if location is closed that day
    // if location does not serve that time of day
    public static func getSpecificMenu(location: Location, timeOfDay: TimeOfDay, completion: @escaping (Menu?) -> Void) {
        // check the local storage of menus
        if let _menus = menus {
            guard let dict = _menus[location]?[timeOfDay] else {
                return completion(nil)
            }
            return completion(dict)
        } else { // if the local storage doesn't exist, pull from the api
            self.getAllMenus { menuDict in
                guard let dict = menuDict[location]?[timeOfDay] else {
                    return completion(nil)
                }
                return completion(dict)
            }
        }
    }
    
    // return every menu for every location and time of day
    private static func getAllMenus(completion: @escaping (MenuDict) -> Void) {
        var menus = MenuDict()
        let group1 = DispatchGroup()
        for loc in locations {
            // dispatch groups are used to synchronously perform the API fetch
            group1.enter()
            getJSONFromURL(urlPath: getURL(location: loc, date: todaysDate)) { jsonData in
                if let json = jsonData {
                    let dict = getMenuFromJSON(json, location: loc)
                    menus[loc] = dict
                }
                group1.leave()
            }
        }
        group1.notify(queue: .main) {
            // set the local storage variable for future use
            self.menus = menus
            return completion(menus)
        }
    }
    
    private static func getMenuFromJSON(_ json: JSON, location loc: Location) -> [TimeOfDay : Menu] {
        // if there is data
        var dict: [TimeOfDay : Menu] = [:]
        for timeOfDay in timesOfDay {
            let menu = getMenu(json: json, location: loc, timeOfDay: timeOfDay)
            if let menuObj = menu { // if the data is properly formed (the location is open at the specified time of day)
                dict[timeOfDay] = menuObj
            }
        }
        return dict
    }
    
    
    // returns the menu for a specific location and time of day
    private static func getMenu(json: JSON, location: Location, timeOfDay: TimeOfDay) -> Menu? {
        let timeOfDayString: String = getTimeOfDayString(from: timeOfDay)
        
        let periodsArray: [JSON] = json["menu"]["periods"].arrayValue
        
        // get rid of for loop and use indexing of a dictionary
        for period in periodsArray {
            let timeOfDayName: String = period["name"].stringValue
            if timeOfDayName == timeOfDayString {
                let categories: [JSON] = period["categories"].arrayValue
                var mealStations: [MealStation] = []
                for category in categories {
                    let mealStation = getMealStationFromCategory(category)
                    mealStations.append(mealStation)
                }
                print("menu: \(Menu(location: location, timeOfDay: timeOfDay, mealStations: mealStations))")
                return Menu(location: location, timeOfDay: timeOfDay, mealStations: mealStations)
                
            }
        }
        return nil
    }
    
    private static func getMealStationFromCategory(_ category: JSON) -> MealStation {
        let name: String = category["name"].stringValue
        print("name: \(name)")
        let itemList: [JSON] = category["items"].arrayValue
        var items: [Item] = []
        for item in itemList {
            let name: String = item["name"].stringValue
            var ingredients: String = item["ingredients"].stringValue
            ingredients = ingredients.replacingOccurrences(of: "&amp;", with: "&")
            items.append(Item(name: name, ingredients: ingredients, image: nil))
        }
        return MealStation(title: name, items: items)
    }
    
    // returns the JSON data from the given url
    // uses Alamofire
    private static func getJSONFromURL(urlPath: String, completion: @escaping (JSON?) -> Void) {
        Alamofire.request(urlPath).responseJSON { response in
            if response.result.isSuccess {
                print("Success")
                let json: JSON = JSON(response.result.value!)
                return completion(json)
            } else {
                print("Failure")
                print("Error \(String(describing: response.result.error))")
                return completion(nil)
            }
        }
    }
    
//    private static func setAllImages(menuDict: MenuDict, completion: @escaping (MenuDict) -> Void) {
//        let group = DispatchGroup()
//        for loc in locations {
//            for timeOfDay in timesOfDay {
//                if let menu: Menu = menuDict[loc]?[timeOfDay] {
//                    for mealStation in menu.mealStations {
//                        for item in mealStation.items {
//                            group.enter()
//                            ImageService.getImageURLFromFirestore(name: item.name) { urlOpt in
//                                if let url = urlOpt {
//                                    ImageService.imageFromUrl(url: url, completion: { img in
//                                        item.image = img
//                                        group.leave()
//                                    })
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        group.notify(queue: .main) {
//            return completion(menuDict)
//        }
//    }
    
    // translate the given location to its id
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
    
    // translates the given time of day to its String counterpart
    private static func getTimeOfDayString(from timeOfDay: TimeOfDay) -> String {
        switch timeOfDay {
        case .Breakfast:
            return "Breakfast"
        case .Lunch:
            return "Lunch"
        case .Dinner:
            return "Dinner"
        }
    }
    
    // gets the URL given the location and today's date
    private static func getURL(location: Location, date: String) -> String {
        return "https://api.dineoncampus.com/v1/location/menu?site_id=5751fd2b90975b60e048929a&location_id=" + self.getLocationID(from: location) + "&platform=0&date=\(date)";
    }
}
