//
//  SteastViewController.swift
//  NUDining
//
//  Created by Nils Backe on 12/22/18.
//  Copyright © 2018 Plus Hundred. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet
import SpringIndicator
import MessageUI

class MenuViewController : UIViewController, UISearchBarDelegate {
    
    var mealStations: [MealStation]?
    var breakfastMealStations: [MealStation]?
    var lunchMealStations: [MealStation]?
    var dinnerMealStations: [MealStation]?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var location: Location = .Steast
    
    @IBOutlet weak var tableView: UITableView!
    
    var currIdx: Int = -1
    
    public let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchBar.barTintColor = AppDelegate.navBarColor
        navigationController?.navigationBar.barTintColor = AppDelegate.navBarColor
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Menu..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(onSendFeedback))
        print("1view did load currIdx: \(self.currIdx)")
        let userDefaults = UserDefaults.standard
        self.currIdx = userDefaults.integer(forKey: "index")
        print("2view did load currIdx: \(self.currIdx)")
        self.segmentedControl.selectedSegmentIndex = self.currIdx
        let selectedIndex = self.tabBarController?.tabBar.tag
        switch selectedIndex {
        case 0:
            location = .Steast
            navigationItem.title = "Stetson East"
        case 1:
            location = .IV
            navigationItem.title = "International Village"
        case 2:
            location = .Stwest
            navigationItem.title = "Stetson West"
        default:
            location = .Steast
            navigationItem.title = "Stetson East"
        }
    }
    
    @objc private func onSendFeedback(_ sender: Any) {
        self.sendEmail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        self.navigationItem.title = parent?.restorationIdentifier
        switch self.navigationItem.title {
        case "Stetson East":
            location = .Steast
        case "International Village":
            location = .IV
        case "Stetson West":
            location = .Stwest
        default:
            location = .Steast
        }
        print("viewwillappear currIdx: \(self.currIdx)")
        let userDefaults = UserDefaults.standard
        self.currIdx = userDefaults.integer(forKey: "index")
        self.segmentedControl.selectedSegmentIndex = self.currIdx
        refreshMenuData()
    }
    
    private func refreshMenuData() {
        let group = DispatchGroup()
        group.enter()
        MenuService.getSpecificMenu(location: location, timeOfDay: .Breakfast) { menu in
            self.breakfastMealStations = menu?.mealStations
            group.leave()
        }
        group.enter()
        MenuService.getSpecificMenu(location: location, timeOfDay: .Lunch) { menu in
            self.lunchMealStations = menu?.mealStations
            group.leave()
        }
        group.enter()
        MenuService.getSpecificMenu(location: location, timeOfDay: .Dinner) { menu in
            self.dinnerMealStations = menu?.mealStations
            group.leave()
        }
        group.notify(queue: .main) {
            self.indexChanged("")
            self.tableView.reloadData()
        }
        
    }
    @IBAction func indexChanged(_ sender: Any) {
        self.currIdx = self.segmentedControl.selectedSegmentIndex
        let defaults = UserDefaults.standard
        defaults.set(currIdx, forKey: "index")
        switch self.currIdx {
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
        print("index changed currIdx: \(self.currIdx)")
    }
}

extension MenuViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.tableView.reloadData()
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

extension MenuViewController : UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
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
        cell.parent = self
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
        return 165.0
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.init(named: "closed")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Dining Hall Closed")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "\(self.navigationItem.title ?? "") is closed today at this time.") 
    }
}

extension MenuViewController: MFMailComposeViewControllerDelegate {
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["backe.n@husky.neu.edu", "barde.n@husky.neu.edu", "xifaras.s@husky.neu.edu", "barnhart.ja@husky.neu.edu"])
            mail.setMessageBody("<p>Hello meNU app team, </p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            self.presentAlert(title: "Cannot send feedback", errorMessage: "This device is unable to send emails")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
