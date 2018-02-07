//
//  ProductAPI.swift
//  Product-Hunt
//
//  Created by Erick Sanchez on 2/5/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import Moya

enum ProductHuntAPIEndPoints {
    case TodaysProducts
    case Comments(for: Product)
}

extension ProductHuntAPIEndPoints: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.producthunt.com/v1/")!
    }
    
    var path: String {
        switch self {
        case .TodaysProducts:
            return "posts"
        case .Comments:
            return "comments"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data(base64Encoded: "not tested")!
    }
    
    var task: Task {
        switch self {
        case .TodaysProducts:
            return .requestPlain
        case .Comments(let post):
            return .requestParameters(parameters: ["search[post_id]": String(post.id)], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return [
            "Authorization": "Bearer 40d589a0340b7659eddeca24cdfe28f43337b684fbae6ef85c9e228ebeb0b1b4",
            "Host" : "api.producthunt.com",
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
    }
}
