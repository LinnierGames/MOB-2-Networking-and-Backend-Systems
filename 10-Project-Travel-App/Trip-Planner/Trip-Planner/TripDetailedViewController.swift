//
//  TripDetailedViewController.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/19/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class TripDetailedViewController: UIViewController {
    
    var trip: TPTrip!
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show editor":
                let nc = segue.destination as! UINavigationController
                let vc = nc.topViewController as! TripEditorTableViewController
                vc.trip = trip
            default: break
            }
        }
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = trip.title
    }

}
