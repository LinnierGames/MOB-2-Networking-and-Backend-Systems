//
//  LoginViewModel+Moya.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/13/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import Moya

struct JSONUser: Codable {
    let id: String?
    let username: String?
    let email: String
    let password: String?
    
    init(id: String? = nil, username: String?, email: String, password: String?) {
        self.id = id
        self.username = username
        self.email = email
        self.password = password
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username
        case email
        case password
    }
}

extension TPUser {
    var jsonBody: JSONUser {
        return JSONUser(id: self.id, username: self.username, email: self.email, password: nil)
    }
}

enum LoginAPIEndpoints {
    case Login(JSONUser)
    case Register(JSONUser)
}

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
            return .requestJSONEncodable(user)
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
