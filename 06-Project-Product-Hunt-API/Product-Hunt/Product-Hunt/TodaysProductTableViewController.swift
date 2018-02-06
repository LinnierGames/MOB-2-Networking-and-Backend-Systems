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
        cell.configure(post: product)
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show product details":
                let vc = segue.destination as! ProductDetailsViewController
                if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                    let product = products![indexPath.row]
                    vc.product = product
                }
            default: break
            }
        }
    }
    
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
