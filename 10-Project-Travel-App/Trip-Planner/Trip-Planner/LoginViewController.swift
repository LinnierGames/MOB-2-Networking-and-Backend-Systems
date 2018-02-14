//
//  LoginViewController.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/13/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController, LoginViewModelDelegate {

    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var textfieldUsername: UITextField!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var textfieldEmail: UITextField!
    @IBOutlet weak var labelPassword: UILabel!
    @IBOutlet weak var textfieldPassword: UITextField!
    
    lazy var loginViewModel = LoginViewModel(delegate: self)
    
    // MARK: - RETURN VALUES
    
    // MARK: - VOID METHODS
    
    private func dismiss() {
        textfieldUsername?.resignFirstResponder()
        textfieldEmail.resignFirstResponder()
        textfieldPassword.resignFirstResponder()
    }
    
    // MARK: View Model Delegate
    
    func loginModel(_ model: LoginViewModel, loginWasSuccessful success: Bool, message: String) {
        if success {
            //TODO: fix dismissing and presting the main view from login screen
            if let parentVc = self.presentingViewController, !(parentVc is LoginViewController) {
                self.presentingViewController?.dismiss(animated: true)
            } else {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                guard let topVc = mainStoryboard.instantiateInitialViewController() else {
                    return assertionFailure("instantiateInitialViewController not set")
                }
                
                topVc.modalTransitionStyle = .flipHorizontal
                self.present(topVc, animated: true)
            }
        } else {
            let alertError = UIAlertController(title: "Logging in", message: "error: \(message)", preferredStyle: .alert)
            alertError.addAction(UIAlertAction(title: "Dismiss", style: .default))
            
            self.present(alertError, animated: true)
        }
    }
    
    func loginModel(_ model: LoginViewModel, registerWasSuccessful success: Bool, message: String) {
        if success {
            loginViewModel.login()
        } else {
            let alertError = UIAlertController(title: "Registering", message: "error: \(message)", preferredStyle: .alert)
            alertError.addAction(UIAlertAction(title: "Dismiss", style: .default))
            
            self.present(alertError, animated: true)
        }
    }
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonLogin: UIButton?
    @IBAction func pressLogin(_ sender: Any) {
        loginViewModel.login()
        dismiss()
    }
    
    @IBOutlet weak var buttonRegister: UIButton?
    @IBAction func pressRegister(_ sender: Any) {
        loginViewModel.register()
        dismiss()
    }
    
    @IBAction func pressBackToLogin(_ sender: Any) {
        self.presentingViewController!.dismiss(animated: true)
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textfieldUsername?.rx.text.bind(to: loginViewModel.username).disposed(by: loginViewModel.bag)
        textfieldEmail.rx.text.bind(to: loginViewModel.email).disposed(by: loginViewModel.bag)
        textfieldPassword.rx.text.bind(to: loginViewModel.password).disposed(by: loginViewModel.bag)
        
        if buttonLogin != nil {
//            buttonLogin!.rx.tap.asDriver().drive(onNext: loginViewModel.login).disposed(by: loginViewModel.bag)
        } else if buttonRegister != nil {
            loginViewModel.isValid().asObservable().bind(to: buttonRegister!.rx.isEnabled).disposed(by: loginViewModel.bag)
//            buttonRegister!.rx.tap.asDriver().drive(onNext: loginViewModel.register).disposed(by: loginViewModel.bag)
        }
    }

}
