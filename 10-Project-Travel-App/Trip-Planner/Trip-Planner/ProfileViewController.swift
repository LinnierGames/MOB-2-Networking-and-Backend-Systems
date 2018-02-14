//
//  ProfileViewController.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/14/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var textfieldPassword: UITextField!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var buttonSave: UIBarButtonItem!
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    @IBAction func pressSave(_ sender: Any) {
    }
    
    @IBAction func pressLogout(_ sender: Any) {
        //TODO: into view model
        let loginVc = UIStoryboard(storyboard: .Login).instantiateInitialViewController()!
        
        PersistenceStack.loggedInUserToken = nil
        
        self.present(loginVc, animated: true)
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        buttonSave.isEnabled = false
    }

}
