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
import SDWebImage

class CustomTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var items: [Item] {
        didSet {
            self.filteredItems = items
        }
    }
    
    var filteredItems: [Item]
    
    var parent: MenuViewController!
    
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
        
        cell.imageView.contentMode = .scaleAspectFill
        if let img = filteredItems[indexPath.item].image {
            cell.imageView.image = img
        } else {
            cell.imageView?.image = UIImage.init(named: "placeholder")
            ImageService.getImageURLFromFirestore(name: name) { urlOpt in
                if let url = urlOpt {
                    cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder"), options: SDWebImageOptions.continueInBackground) {
                        (image, error, cacheType, imageURL) in
                        if self.filteredItems.count > indexPath.item {
                            self.filteredItems[indexPath.item].image = image
                        }
                    }
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
        print("didSelectItemAt")
        if self.parent.searchController.isActive {
            self.parent.searchController.dismiss(animated: true) {
                self.showPopup(indexPath: indexPath)
            }
        } else {
            self.showPopup(indexPath: indexPath)
        }
    }
    
    private func showPopup(indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ItemDetailViewController", bundle: nil)
        let customAlert = storyboard.instantiateViewController(withIdentifier: "ItemDetailViewController") as! ItemDetailViewController
        customAlert.providesPresentationContextTransitionStyle = true
        customAlert.definesPresentationContext = true
        customAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        customAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        customAlert.item = filteredItems[indexPath.row]
        self.parent.present(customAlert, animated: true)
    }
}
