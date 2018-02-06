//
//  ProductCommentsTableViewController.swift
//  Product-Hunt
//
//  Created by Erick Sanchez on 2/5/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class ProductCommentsTableViewController: UITableViewController {
    
    var product: Product? {
        didSet {
            product?.comments(complition: { (result) in
                if let comments = result {
                    self.comments = comments
                }
            })
        }
    }
    
    private var comments: [CommentsResult.Comment]? {
        didSet {
            tableView?.reloadData()
        }
    }
    
    // MARK: - RETURN VALUES
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Comments"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        guard let comments = comments else {
            assertionFailure("no comments were found")
            
            return cell
        }
        
        let comment = comments[indexPath.row]
        cell.labelTitle.text = comment.user.username
        cell.labelSubtitle.text = comment.body
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 38
    }

}
