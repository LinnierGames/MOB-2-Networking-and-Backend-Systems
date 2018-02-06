//
//  ProductDetailsViewController.swift
//  Product-Hunt
//
//  Created by Erick Sanchez on 2/5/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class ProductDetailsViewController: UIViewController {
    
    var product: Product?
    
    @IBOutlet weak var embeddedTableView: UIView!

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var tagline: UITextView!
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "comments table":
                let vc = segue.destination as! ProductCommentsTableViewController
                vc.product = product
            default: break
            }
        }
    }
    
    private func updateUI() {
        guard let product = product else {
            return assertionFailure("product was not set")
        }
        
        thumbnail.kf.setImage(with: product.thumbnail.imageUrl)
        title = product.name
        tagline.text = product.tagline
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }

}
