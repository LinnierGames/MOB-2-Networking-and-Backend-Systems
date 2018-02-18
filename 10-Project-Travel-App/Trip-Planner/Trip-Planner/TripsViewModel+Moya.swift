//
//  TripsViewModel+Moya.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/17/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import Moya

struct JSONTrip {
    let title: String
    
    let uesr: TPUser!
}

enum TripAPIEndpoints {
    case AddTrip(JSONTrip)
}

extension TripAPIEndpoints: TargetType {
    var baseURL: URL {
        return apiUrl
    }
    
    var path: String {
        switch self {
        case .AddTrip:
            return "/trip/"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        return "nothing yet".data(using: .utf8)!
    }
    
    var task: Task {
        switch self {
        case .AddTrip(let trip):
            return .requestJSONEncodable(trip)
    }
        
    var headers: [String : String]? {
        var defaultHeader = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        switch self {
        case .AddTrip(let trip):
            guard let token = PersistenceStack.loggedInUserToken else {
                preconditionFailure("User logged in without a stored token in keychains")
            }
            
            defaultHeader["Auth"] = token
            
            return defaultHeader
        }
    }
}
