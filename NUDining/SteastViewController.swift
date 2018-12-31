//
//  SteastViewController.swift
//  NUDining
//
//  Created by Nils Backe on 12/22/18.
//  Copyright © 2018 Plus Hundred. All rights reserved.
//

import Foundation
import UIKit

class SteastViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var menu: Menu?
    var breakfast: Menu?
    var lunch: Menu?
    var dinner: Menu?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let group = DispatchGroup()
        group.enter()
        MenuService.getSpecificMenu(location: .Steast, timeOfDay: .Breakfast) { menu in
            self.breakfast = menu
            group.leave()
        }
        group.enter()
        MenuService.getSpecificMenu(location: .Steast, timeOfDay: .Lunch) { menu in
            self.lunch = menu
            group.leave()
        }
        group.enter()
        MenuService.getSpecificMenu(location: .Steast, timeOfDay: .Dinner) { menu in
            self.dinner = menu
            group.leave()
        }
        group.notify(queue: .main) {
            self.indexChanged("")
        }
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.menu = self.breakfast
        case 1:
            self.menu = self.lunch
        case 2:
            self.menu = self.dinner
        default:
            break
        }
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // change
        return menu?.mealStations.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!
        let title = menu?.mealStations[indexPath.row].title
        cell.textLabel?.text = title
        if let _title = title {
//            ImageService.getImageFromKeyword(q: _title) { img in
//                if let _img = img {
//                    cell.backgroundView = UIImageView(image: _img)
//                    cell.backgroundView?.contentMode = UIView.ContentMode.scaleAspectFill
//                }
//            }
        }
        return cell
    }
}
