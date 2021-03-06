//
//  NotificationsViewController.swift
//  NUDining
//
//  Created by Nils Backe on 12/22/18.
//  Copyright © 2018 Plus Hundred. All rights reserved.
//

import Foundation
import UIKit

class NotificationsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var preferredFoods: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FoodService.getPreferredFoods { foods in
            self.preferredFoods = foods
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preferredFoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!
        cell.textLabel?.text = preferredFoods[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let removedFood = preferredFoods.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            FoodService.removePreferredFood(removedFood) { bool in
                if (!bool) {
                    print("could not revome food from database")
                }
            }
        }
    }
}
