//
//  SteastViewController.swift
//  NUDining
//
//  Created by Nils Backe on 12/22/18.
//  Copyright © 2018 Plus Hundred. All rights reserved.
//

import Foundation
import UIKit

class SteastViewController : UIViewController, UISearchBarDelegate {
    
    var mealStations: [MealStation]?
    var breakfastMealStations: [MealStation]?
    var lunchMealStations: [MealStation]?
    var dinnerMealStations: [MealStation]?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        navigationItem.title = "Stetson East"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchBar.barTintColor = AppDelegate.navBarColor
        navigationController?.navigationBar.barTintColor = AppDelegate.navBarColor
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Menu"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let group = DispatchGroup()
        group.enter()
        MenuService.getSpecificMenu(location: .Steast, timeOfDay: .Breakfast) { menu in
            self.breakfastMealStations = menu?.mealStations
            group.leave()
        }
        group.enter()
        MenuService.getSpecificMenu(location: .Steast, timeOfDay: .Lunch) { menu in
            self.lunchMealStations = menu?.mealStations
            group.leave()
        }
        group.enter()
        MenuService.getSpecificMenu(location: .Steast, timeOfDay: .Dinner) { menu in
            self.dinnerMealStations = menu?.mealStations
            group.leave()
        }
        group.notify(queue: .main) {
            self.indexChanged("")
        }
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.mealStations = self.breakfastMealStations?.sorted {$0.title < $1.title}
        case 1:
            self.mealStations = self.lunchMealStations?.sorted {$0.title < $1.title}
        case 2:
            self.mealStations = self.dinnerMealStations?.sorted {$0.title < $1.title}
        default:
            break
        }
        self.tableView.reloadData()
    }
}

extension SteastViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        tableView.reloadData()
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return self.searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension SteastViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mealStations?[section].title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return mealStations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath) as! CustomTableViewCell
        if isFiltering() {
            cell.items = mealStations![indexPath.section].items
            cell.filter(by: searchController.searchBar.text ?? "")
        } else {
            cell.items = mealStations![indexPath.section].items
            cell.resetFiltering()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
}
