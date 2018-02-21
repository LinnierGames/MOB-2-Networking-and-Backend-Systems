//
//  TripDetailedTableViewController.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/19/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class TripEditorTableViewController: UITableViewController {
    
    var trip: TPTrip?
    
    private var viewModel = TripsViewModel()
    
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
        if trip == nil {
            guard
                let newTitle = textfieldTitle.text
                else {
                    preconditionFailure("no user logged in")
            }
            
            let newTrip = TPTrip(title: newTitle)
            viewModel.add(a: newTrip, complition: { (result) in
                switch result {
                case .success:
                    self.presentingViewController!.dismiss(animated: true)
                case .failure(let error):
                    let alert = UIAlertController(title: "Adding a Trip", message: "failed: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alert, animated: true)
                }
            })
        } else {
            
        }
    }
    
    @IBAction func pressDiscard(_ sender: Any) {
        if hasChanges {
            
        }
        self.presentingViewController!.dismiss(animated: true)
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.rowHeight = 44
        updateUI()
    }

}
