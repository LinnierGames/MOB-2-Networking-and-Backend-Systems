//
//  KeychainsStack.swift
//  circuit-studio
//
//  Created by Erick Sanchez on 2/12/18.
//  Copyright © 2018 Circuit Studio. All rights reserved.
//

import Foundation
import KeychainSwift

struct PersistenceStack {
    
    fileprivate static let LOGGED_IN_TOKEN = "LOGGED_IN_TOKEN"
    static var loggedInUserToken: String? {
        set {
            let keychain = KeychainSwift()
            if let token = newValue {
                keychain.set(token, forKey: LOGGED_IN_TOKEN)
            } else {
                keychain.delete(LOGGED_IN_TOKEN)
            }
        }
        get {
            let keychain = KeychainSwift()
            
            return keychain.get(LOGGED_IN_TOKEN)
        }
    }
    
//    fileprivate static let LOGGED_IN_USER_ID = "LOGGED_IN_USER_ID"
//    static var loggedInUserId: String? {
//        set {
//            let userDefaults = UserDefaults.standard
//            userDefaults.set(newValue, forKey: LOGGED_IN_USER_ID)
//            userDefaults.synchronize()
//        }
//        get {
//            let ud = UserDefaults.standard
//
//            return ud.string(forKey: LOGGED_IN_USER_ID)
//        }
//    }
}

