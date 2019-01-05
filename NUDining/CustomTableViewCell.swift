//
//  CustomTableViewCell.swift
//  NUDining
//
//  Created by Nils Backe on 12/31/18.
//  Copyright © 2018 Plus Hundred. All rights reserved.
//

import Foundation
import UIKit

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
        
        cell.nameLabel.text = filteredItems[indexPath.item].name
        cell.ingredientsLabel.text = filteredItems[indexPath.item].ingredients
//        ImageService.getImageFromKeyword(q: (items?[indexPath.item].name)!) { image in
//            cell.backgroundView = UIImageView(image: image)
//        }
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let size = CGSize(width: 150, height: 120)
//        return size
//    }
}
