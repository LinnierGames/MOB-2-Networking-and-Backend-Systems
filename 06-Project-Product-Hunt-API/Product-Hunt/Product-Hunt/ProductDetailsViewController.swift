//
//  ProductDetailsViewController.swift
//  Product-Hunt
//
//  Created by Erick Sanchez on 2/5/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class ProductDetailsViewController: UIViewController {
    
    var product: Product!

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var tagline: UITextView!
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        thumbnail.kf.setImage(with: product.thumbnail.imageUrl)
        title = product.name
        tagline.text = product.tagline
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard product != nil else {
            return assertionFailure("product was not set")
        }
        
        updateUI()
        
    }

}
