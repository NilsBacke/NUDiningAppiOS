//
//  AddPreferredFoodViewController.swift
//  NUDining
//
//  Created by Nils Backe on 12/23/18.
//  Copyright © 2018 Plus Hundred. All rights reserved.
//

import Foundation
import UIKit

class AddPreferredFoodViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var foods: [String] = [] {
        didSet {
            self.filteredFoods = foods
        }
    }
    var filteredFoods: [String] = []
    
    lazy var searchBar: UISearchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        searchBar.searchBarStyle = UISearchBar.Style.prominent
        
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FoodService.getAllFoods { foods in
            self.foods = foods
            self.tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange textSearched: String) {
        if !textSearched.isEmpty {
            self.filteredFoods = foods.filter { food in
                return food.lowercased().contains(textSearched.lowercased())
            }
        } else {
            self.filteredFoods = self.foods
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        FoodService.addPreferredFood(filteredFoods[indexPath.row]) { bool in
            if !bool {
                print("could not add preferred food")
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFoods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier2")!
        cell.textLabel?.text = filteredFoods[indexPath.row]
        return cell
    }
    
}
