//
//  TripsViewModel+Moya.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/17/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import Moya

struct JSONTrip: Codable {
    let title: String
    let user: TPUser! = nil
    
    enum CodingKeyse: String, CodingKey {
        case title
    }
}

extension TPTrip {
    var jsonBody: JSONTrip {
        return JSONTrip(title: self.title)
    }
}

enum TripAPIEndpoints {
    case AddTrip(JSONTrip)
    case Trips(for: JSONUser)
}

extension TripAPIEndpoints: TargetType {
    var baseURL: URL {
        return apiUrl
    }
    
    var path: String {
        switch self {
        case .AddTrip:
            return "/trip/"
        case .Trips(let user):
            if let userId = user.id {
                return "/user/\(userId)/trips"
            } else {
                preconditionFailure("TPUser does not have an id")
            }
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .AddTrip:
            return .post
        case .Trips:
            return .get
        }
    }
    
    var sampleData: Data {
        return "nothing yet".data(using: .utf8)!
    }
    
    var task: Task {
        switch self {
        case .AddTrip(let trip):
            return .requestJSONEncodable(trip)
        case .Trips:
            return .requestPlain
        }
    }
        
    var headers: [String : String]? {
        var defaultHeader = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        switch self {
        case .AddTrip, .Trips:
            guard
                let token = PersistenceStack.loggedInUserToken,
                /** uses the logged in user_id to authorize this POST */
                let userId = PersistenceStack.loggedInUser?.id else {
                preconditionFailure("User logged in without a stored token in keychains")
            }
            
            defaultHeader["Auth"] = token
            defaultHeader["user"] = userId
            
            return defaultHeader
        }
    }
}
