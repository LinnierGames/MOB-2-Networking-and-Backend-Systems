//
//  ProfileViewModel+Moya.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/14/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import Moya

enum ProfileAPIEndpoints {
    case UpdatePassword(JSONUser, String)
}

extension ProfileAPIEndpoints: TargetType {
    var baseURL: URL {
        return apiUrl
    }

    var path: String {
        switch self {
        case .UpdatePassword(let user, _):
            if let userId = user.id {
                return "/user/\(userId)"
            } else {
                preconditionFailure("TPUser does not have an id")
            }
        }
    }

    var method: Moya.Method {
        switch self {
        case .UpdatePassword:
            return .patch
        }
    }

    var sampleData: Data {
        return "nothing yet".data(using: .utf8)!
    }

    var task: Task {
        switch self {
        case .UpdatePassword(_, let newPassword):
            return .requestJSONEncodable(["password": newPassword])
        }
    }

    var headers: [String : String]? {
        var defaultHeader = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        switch self {
        case .UpdatePassword:
            guard let token = PersistenceStack.loggedInUserToken else {
                preconditionFailure("User logged in without a stored token in keychains")
            }
            
            defaultHeader["Auth"] = token
            
            return defaultHeader
        }
    }
}



