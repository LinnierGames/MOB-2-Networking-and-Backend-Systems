//
//  LoginViewModel+Moya.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/13/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import Moya

struct UserHTTPBody: Codable {
    let username: String?
    let email: String
    let password: String
}

enum LoginAPIEndpoints {
    case Login(UserHTTPBody)
    case Register(UserHTTPBody)
}

#if DEBUG
    let apiUrl = URL(string: "http://127.0.0.1:5000")!
#else
    let apiUrl: URL = { fatalError("not implelemnted") }()
#endif

extension LoginAPIEndpoints: TargetType {
    var baseURL: URL {
        return apiUrl
    }
    
    var path: String {
        switch self {
        case .Register:
            return "/register"
        case .Login:
            return "/auth/login"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        return "nothing yet".data(using: .utf8)!
    }
    
    var task: Task {
        switch self {
        case .Register(let user):
            return .requestData(try! JSONEncoder().encode(user))
        case .Login(let user):
            return .requestJSONEncodable(user)
        }
    }
    
    var headers: [String : String]? {
        let defaultHeader = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        switch self {
        case .Register, .Login:
            return defaultHeader
        }
    }
}
