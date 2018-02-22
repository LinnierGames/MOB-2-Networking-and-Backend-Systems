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

//TODO: use RxSwift to communicate back to the view controller
protocol LoginViewModelDelegate {
    func loginModel(_ model: LoginViewModel, loginWasSuccessful success: Bool, message: String)
    func loginModel(_ model: LoginViewModel, registerWasSuccessful success: Bool, message: String)
}

struct LoginViewModel {
    
    var delegate: LoginViewModelDelegate
    
    private let apiProvider = MoyaProvider<LoginAPIEndpoints>()
    
    private var bag = DisposeBag()
    
    var username = Variable<String?>(nil)
    var email = Variable<String?>(nil)
    var password = Variable<String?>(nil)
    
    init(delegate: LoginViewModelDelegate) {
        self.delegate = delegate
    }
    
    //TODO: validate for empty fields
    
    /**
     Login a user and save token into Keychains
     */
    func login(unsuccessful: () -> ()) {
        let user = JSONUser(username: nil, email: email.value!, password: password.value!)
        apiProvider.request(.Login(user)) { (result) in
            switch result {
            case .success(let res):
                guard let resMessage = JSON(res.data).dictionary?["message"]?.string else {
                    return assertionFailure("failed to get message from response")
                }
                
                switch res.statusCode {
                case 202:
                    guard
                        let token = JSON(res.data).dictionary?["auth_token"]?.string,
                        let userDataJson = JSON(res.data).dictionary?["data"],
                        let userData = try? userDataJson.rawData(options: .prettyPrinted),
                        let user = try? JSONDecoder().decode(TPUser.self, from: userData)
                        else {
                            return assertionFailure("missing auth_token fromp api")
                    }
                    
                    PersistenceStack.loggedInUser = user
                    PersistenceStack.loggedInUserToken = token
                    
                    self.delegate.loginModel(self, loginWasSuccessful: true, message: resMessage)
                case 401: //wrong login
                    self.delegate.loginModel(self, loginWasSuccessful: false, message: resMessage)
                case 404: //Not found
                    self.delegate.loginModel(self, loginWasSuccessful: false, message: resMessage)
                case 500: //internal error
                    self.delegate.loginModel(self, loginWasSuccessful: false, message: resMessage)
                default:
                    break
                }
            case .failure(let error):
                self.delegate.loginModel(self, loginWasSuccessful: false, message: error.localizedDescription)
            }
        }
    }
    
    /**
     Register a user
     */
    func register(unsuccessful: () -> ()) {
        let user = JSONUser(username: username.value, email: email.value!, password: password.value!)
        apiProvider.request(.Register(user)) { (result) in
            switch result {
            case .success(let res):
                switch res.statusCode {
                case 201:
                    self.delegate.loginModel(self, registerWasSuccessful: true, message: "success")
                case 400: //missing fields
                    self.delegate.loginModel(self, registerWasSuccessful: false, message: "cannot have missing fields")
                case 403: //user already exsits
                    guard
                        let ununiqueFieldMessage = JSON(res.data).dictionary?["message"]?.string
                        else {
                            return assertionFailure("cannot cast json -> string")
                    }
                    
                    self.delegate.loginModel(self, registerWasSuccessful: false, message: ununiqueFieldMessage)
                case 500: //internal error
                    self.delegate.loginModel(self, registerWasSuccessful: false, message: "internal server error has occured")
                default:
                    assertionFailure("unhandled status code")
                }
            case .failure(let error):
                self.delegate.loginModel(self, registerWasSuccessful: false, message: error.localizedDescription)
            }
        }
    }
}
