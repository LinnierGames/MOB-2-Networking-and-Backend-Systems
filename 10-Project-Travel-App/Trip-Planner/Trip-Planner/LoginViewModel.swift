//
//  LoginViewModel.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/13/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import SwiftyJSON

protocol LoginViewModelDelegate {
    func loginModel(_ model: LoginViewModel, loginWasSuccessful success: Bool, message: String)
    func loginModel(_ model: LoginViewModel, registerWasSuccessful success: Bool, message: String)
}

struct LoginViewModel {
    
    var delegate: LoginViewModelDelegate
    
    let apiProvider = MoyaProvider<LoginAPIEndpoints>()
    
    var bag = DisposeBag()
    
    var username = Variable<String?>(nil)
    var email = Variable<String?>(nil)
    var password = Variable<String?>(nil)
    
    init(delegate: LoginViewModelDelegate) {
        self.delegate = delegate
    }
    
    func isValid() -> Variable<Bool> {
        guard
            let emailValue = email.value,
            let passwordValue = password.value
            else {
                return Variable(false)
        }
        
        if username.value != nil {
            if username.value!.count < 6 {
                return Variable(false)
            }
        }
        
        if emailValue.count < 6 || passwordValue.count < 6 {
            return Variable(false)
        }
        
        return Variable(true)
    }
    
    func login() {
        precondition(isValid().value, "Button was clickable while entries were not valid")
        
        let user = UserHTTPBody(username: nil, email: email.value!, password: password.value!)
        apiProvider.request(.Login(user)) { (result) in
            switch result {
            case .success(let response):
                switch response.statusCode {
                //Todo: imnplement login in api
                case 200:
                    self.delegate.loginModel(self, loginWasSuccessful: true, message: "success")
                case 404: //Not found
                    self.delegate.loginModel(self, loginWasSuccessful: false, message: "email not found")
                default:
                    break
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func register() {
        //precondition(isValid().value, "Button was clickable while entries were not valid")
        
        let user = UserHTTPBody(username: username.value, email: email.value!, password: password.value!)
        apiProvider.request(.Register(user)) { (result) in
            switch result {
            case .success(let res):
                switch res.statusCode {
                //Todo: imnplement login in api
                case 201:
                    guard
                        let token = JSON(res.data).dictionary?["auth_token"]?.string
                        else {
                            return assertionFailure("missing auth_token")
                    }
                    
                    PersistenceStack.loggedInUserToken = token
                    
                    self.delegate.loginModel(self, loginWasSuccessful: true, message: "success")
                case 400: //missing fields
                    self.delegate.loginModel(self, loginWasSuccessful: false, message: "cannot have missing fields")
                case 403: //user already exsits
                    guard
                        let ununiqueFieldMessage = JSON(res.data).dictionary?["message"]?.string
                        else {
                            return assertionFailure("cannot cast json -> string")
                    }
                    
                    self.delegate.loginModel(self, registerWasSuccessful: false, message: ununiqueFieldMessage)
                default:
                    assertionFailure("unhandled status code")
                }
            case .failure:
                break
            }
        }
    }
}
