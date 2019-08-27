//
//  IceCreamViewController.swift
//  NUDining
//
//  Created by Nils Backe on 4/9/19.
//  Copyright © 2019 Plus Hundred. All rights reserved.
//

import UIKit

class IceCreamViewController: UIViewController {
    @IBOutlet weak var segmentedController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }

    static func storyboardInstance() -> IceCreamViewController? {
        let storyboard = UIStoryboard(name: "IceCreamViewController", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "IceCreamViewController") as? IceCreamViewController
    }
}

extension IceCreamViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "iceCreamCell", for: indexPath) as! IceCreamTableViewCell
        
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        
        switch indexPath.row {
        case 0:
            cell.dayLabel.text = "Monday"
            cell.flavorOne.text = "Strawberry"
            cell.flavorTwo.text = "Chocolate"
        case 1:
            cell.dayLabel.text = "Tuesday"
            cell.flavorOne.text = "Raspberry Chocolate"
            cell.flavorTwo.text = "Vanilla"
        case 2:
            cell.dayLabel.text = "Wednesday"
            cell.flavorOne.text = "Vanilla"
            cell.flavorTwo.text = "Mint Chocolate"
        case 3:
            cell.dayLabel.text = "Thursday"
            cell.flavorOne.text = "Orange Cream"
            cell.flavorTwo.text = "Vanilla"
        case 4:
            cell.dayLabel.text = "Friday"
            cell.flavorOne.text = "Mocha"
            cell.flavorTwo.text = "Vanilla"
        case 5:
            cell.dayLabel.text = "Saturday"
            cell.flavorOne.text = "Chocolate"
            cell.flavorTwo.text = "Coconut Pineapple"
        case 6:
            cell.dayLabel.text = "Sunday"
            cell.flavorOne.text = "Vanilla"
            cell.flavorTwo.text = "Maple"
        default:
            cell.dayLabel.text = "Monday"
            cell.flavorOne.text = "Strawberry"
            cell.flavorTwo.text = "Chocolate"
            // will never be reached
        }
        
        return cell
        
    }
    
}
