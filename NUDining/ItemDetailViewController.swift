//
//  ItemDetailViewController.swift
//  NUDining
//
//  Created by Nils Backe on 1/15/19.
//  Copyright © 2019 Plus Hundred. All rights reserved.
//

import UIKit
import TTGSnackbar

class ItemDetailViewController: UIViewController {
    
    var item: Item!

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    
    let alertViewGrayColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = item.image
        alertView.clipsToBounds = true
        imageView.clipsToBounds = true
        nameLabel.text = item.name
        ingredientsLabel.text = item.ingredients
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        FoodService.addPreferredFood(item.name) { bool in
            if bool {
                self.showSuccessSnackbar(foodName: self.item.name)
            } else {
                self.showFailureSnackbar(foodName: self.item.name)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showSuccessSnackbar(foodName: String) {
        let snackbar = TTGSnackbar(message: "\(foodName) added",
            duration: .middle)
        snackbar.show()
    }
    
    func showFailureSnackbar(foodName: String) {
        let snackbar = TTGSnackbar(message: "Failed to add \(foodName). Please try again.",
            duration: .middle)
        snackbar.show()
    }
    
}
