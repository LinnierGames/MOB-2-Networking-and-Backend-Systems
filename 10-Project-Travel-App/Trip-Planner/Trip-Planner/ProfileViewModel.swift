//
//  ProfileViewModel.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/14/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import RxSwift

struct ProfileViewModel {
    
    var username = Variable(PersistenceStack.loggedInUser?.username ?? "Oops")
    var email = Variable(PersistenceStack.loggedInUser?.email ?? "Oops")
    var password = Variable<String?>(nil)
    
    func logout() {
        PersistenceStack.logoutUser()
    }
    
    func updatePassword() {
        if let passwordValue = password.value {
            
        }
    }
}
