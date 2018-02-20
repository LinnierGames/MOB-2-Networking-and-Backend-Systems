//
//  TripDetailedTableViewController.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/19/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class TripDetailedTableViewController: UITableViewController {
    
    var trip: TPTrip?
    
    private var hasChanges = false
    
    @IBOutlet weak var textfieldTitle: UITextField!
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private func updateUI() {
        guard let trip = trip else { return }
        
        textfieldTitle.text = trip.title
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonSave: UIBarButtonItem!
    @IBAction func pressSave(_ sender: Any) {
    }
    
    @IBAction func pressDiscard(_ sender: Any) {
        if hasChanges {
            
        }
        self.presentingViewController!.dismiss(animated: true)
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }

}
