//
//  CustomTableViewCell.swift
//  NUDining
//
//  Created by Nils Backe on 12/31/18.
//  Copyright © 2018 Plus Hundred. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView
import TTGSnackbar

class CustomTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var items: [Item] {
        didSet {
            self.filteredItems = items
        }
    }
    var filteredItems: [Item]
    
    override func awakeFromNib() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.items = []
        self.filteredItems = self.items
        super.init(coder: aDecoder)
    }
    
    func filter(by text: String) {
        if !text.isEmpty {
            self.filteredItems = self.items.filter { item in
                return item.name.lowercased().contains(text.lowercased()) || item.ingredients.lowercased().contains(text.lowercased())
            }
            collectionView.reloadData()
        }
    }
    
    func resetFiltering() {
        self.filteredItems = self.items
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        let name = filteredItems[indexPath.item].name
        let ingredients = filteredItems[indexPath.item].ingredients
        cell.nameLabel.text = name
        cell.ingredientsLabel.text = ingredients
        if let img = filteredItems[indexPath.item].image {
            print("image saved")
            cell.imageView.image = img
        } else {
            ImageService.getImageURLFromFirestore(name: name) { urlOpt in
                if let url = urlOpt {
                    ImageService.imageFromUrl(url: url, completion: { img in
                        cell.imageView.image = img
                        if self.filteredItems.count > indexPath.item {
                            self.filteredItems[indexPath.item].image = img
                            print("save image")
                        }
                    })
                }
            }
        }
       
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: 180, height: 160)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let appearance = SCLAlertView.SCLAppearance(
            showCircularIcon: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        let foodName = self.filteredItems[indexPath.row].name
        alertView.addButton("Add") {
            // set prefered food
            FoodService.addPreferredFood(foodName, completion: { bool in
                if bool {
                    self.showSuccessSnackbar(foodName: foodName)
                } else {
                    self.showFailureSnackbar(foodName: foodName)
                }
            })
        }
        alertView.showError("Get Notified", subTitle: "Do you want to add \(foodName) to your preferred foods list to be notified whenever it's on the menu?", closeButtonTitle: "Cancel")
    }
    
    func showSuccessSnackbar(foodName: String) {
        let snackbar = TTGSnackbar(message: "\(foodName) added",
            duration: .middle,
            actionText: "Undo",
            actionBlock: { (snackbar) in
                snackbar.dismiss()
                FoodService.removePreferredFood(foodName, completion: { (bool) in
                    print("undo-ed")
                    let snackbar2 = TTGSnackbar(message: "\(foodName) removed",
                        duration: .middle)
                    snackbar2.show()
                })
        })
        snackbar.show()
    }
    
    func showFailureSnackbar(foodName: String) {
        let snackbar = TTGSnackbar(message: "Failed to add \(foodName). Please try again.",
            duration: .middle)
        snackbar.show()
    }
}
