//
//  TodaysProductTableViewController.swift
//  Product-Hunt
//
//  Created by Erick Sanchez on 2/2/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class TodaysProductTableViewController: UITableViewController {
    
    private var products: [Product]? {
        didSet {
            if let _ = products {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - RETURN VALUES
    
    // MARK: Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        let product = products![indexPath.row]
        cell.labelTitle.text = product.name
        cell.labelTagline.text = product.tagline
        cell.captionVotes.text = String(product.votes)
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ProductNetworkService.fetchProducts(for: .FetchAllProductsForToday) { (result) in
            switch result {
            case .Success(let products):
                self.products = products
            case .Failed(let message):
                print(message)
            }
        }
    }

}
