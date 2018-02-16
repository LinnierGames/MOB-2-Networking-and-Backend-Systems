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
    case UpdatePassword(TPUser, String)
}

//extension ProfileAPIEndpoints: TargetType {
//    var baseURL: URL {
//        return apiUrl
//    }
//
//    var path: String {
//        switch self {
//        case .UpdatePassword(let user, _):
//            return "/auth/\(user.username)"
//        }
//    }
//
//    var method: Moya.Method {
//        switch self {
//        case .UpdatePassword:
//            return .patch
//        }
//    }
//
//    var sampleData: Data {
//        return "nothing yet".data(using: .utf8)!
//    }
//
//    var task: Task {
//        switch self {
//        case .UpdatePassword(let user, let newPassword):
//            break
//        }
//    }
//
//    var headers: [String : String]? {
//        let defaultHeader = [
//            "Content-Type": "application/json",
//            "Accept": "application/json"
//        ]
//        switch self {
//        case .UpdatePassword(let user, _):
//            return defaultHeader
//        }
//    }
//}



