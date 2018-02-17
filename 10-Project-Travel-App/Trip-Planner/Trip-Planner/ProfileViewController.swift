//
//  ProfileViewController.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/14/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var textfieldPassword: UITextField!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var buttonSave: UIBarButtonItem!
    
    let viewModel = ProfileViewModel()
    private var bag = DisposeBag()
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    @IBAction func pressSave(_ sender: Any) {
        textfieldPassword.resignFirstResponder()
        let alertUpdating = UIAlertController(title: "Update Profile", message: "please wait", preferredStyle: .alert)
        viewModel.updatePassword { (result) in
            let alertMessage: String
            switch result {
            case .success(let message):
                alertMessage = message
            case .failure(let errMessage):
                alertMessage = String(describing: errMessage)
            }
            alertUpdating.dismiss(animated: true, completion: {
                let alert = UIAlertController(title: "Update Profile", message: alertMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(alert, animated: true)
            })
            
        }
        self.present(alertUpdating, animated: true)
    }
    
    @IBAction func pressLogout(_ sender: Any) {
        viewModel.logout()
        
        let loginVc = UIStoryboard(storyboard: .Login).instantiateInitialViewController()!
        self.present(loginVc, animated: true)
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        viewModel.username.asObservable()
            .map { "@\($0.lowercased())" }
            .bind(to: labelUsername.rx.text).disposed(by: bag)
        
        viewModel.email.asObservable()
            .bind(to: labelEmail.rx.text).disposed(by: bag)
        
        viewModel.email.asObservable()
            .subscribe { [weak self] (event) in
                if let user = PersistenceStack.loggedInUser {
                    self?.thumbnail.kf.setImage(with: URL(string: user.thumbnail)!)
                }
            }.disposed(by: bag)
        
        textfieldPassword.rx.text
            .subscribe({ [weak self] (event) in
                if let newPassword = event.element {
                    self?.buttonSave.isEnabled = newPassword?.count ?? 0 > 0
                    self?.viewModel.password.value = newPassword
                }
            }).disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        buttonSave.isEnabled = false
    }
    
}

