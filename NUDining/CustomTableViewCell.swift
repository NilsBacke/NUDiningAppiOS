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
import Nuke

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
        
        let item = filteredItems[indexPath.item]
        print("imageURL: \(item.imageURL)")
        let name = item.name
        let ingredients = item.ingredients
        cell.nameLabel.text = name
        cell.ingredientsLabel.text = ingredients
        
        cell.imageView.contentMode = .scaleAspectFill
        if let img = item.image {
            cell.imageView.image = img
        } else {
            cell.imageView.image = UIImage(named: "placeholder")
            if let url = item.imageURL, url.contains("http") {
                print("loading image")
                print(url)
                let task = ImagePipeline.shared.loadImage(
                    with: URL(string: url)!,
                    completion: { response, _ in
                        cell.imageView.image = response?.image
                        item.image = response?.image
                    }
                )
            } else {
                ImageService.fetchImageURLFromBing(query: item.name) { urlOpt in
                    if let url = urlOpt {
                        print("updating image")
                        let urlStr = url.absoluteString
                        item.imageURL = urlStr
                        
                        let task = ImagePipeline.shared.loadImage(
                            with: url,
                            completion: { response, _ in
                                cell.imageView.image = response?.image
                                item.image = response?.image
                        }
                        )
                        ImageService.saveImageURLToFirebase(name: item.name, url: urlStr) { err in
                            if let error = err {
                                print("Picture failed to save to firebase: \(error)")
                            }
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
