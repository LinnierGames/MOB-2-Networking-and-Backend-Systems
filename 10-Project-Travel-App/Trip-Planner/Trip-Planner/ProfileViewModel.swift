//
//  ProfileViewModel.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/14/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import Moya
import Result
import RxSwift
import SwiftyJSON

struct ProfileViewModel {
    
    let apiProvider = MoyaProvider<ProfileAPIEndpoints>()

    var username = Variable(PersistenceStack.loggedInUser?.username ?? "Oops")
    var email = Variable(PersistenceStack.loggedInUser?.email ?? "Oops")
    var password = Variable<String?>(nil)
    
    func logout() {
        PersistenceStack.logoutUser()
    }
    
    enum ProfileAPIErrors: Error {
        case InvalidUserCerdentials
        case SomethingWentWrong(String)
        case ServerError
    }
    
    func updatePassword(complition: @escaping (_ Success: Result<String, ProfileAPIErrors>) -> ()) {
        guard
            let newPassword = password.value,
            let user = PersistenceStack.loggedInUser
            else {
                return
        }
        
        apiProvider.request(.UpdatePassword(user.jsonBody, newPassword)) { (result) in
            switch result {
            case .success(let res):
                switch res.statusCode {
                case 202:
                    guard
                        let jsonBody = JSON(res.data).dictionary,
                        let message = jsonBody["message"]?.string
                        else {
                            return assertionFailure("cannot get message from res.json")
                    }
                    
                    complition(.success(message))
                case 401, 404, 400:
                    complition(.failure(.InvalidUserCerdentials))
                case 500:
                    complition(.failure(.ServerError))
                default:
                    fatalError("Unhandled status code")
                }
            case .failure(let err):
                complition(.failure(.SomethingWentWrong(err.localizedDescription)))
            }
        }
    }
}
