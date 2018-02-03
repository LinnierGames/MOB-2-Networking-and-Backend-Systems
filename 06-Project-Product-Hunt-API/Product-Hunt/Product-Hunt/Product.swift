//
//  Product.swift
//  Product-Hunt
//
//  Created by Erick Sanchez on 2/2/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import UIKit

//TODO: use swifty json to remove the nested container from a network call
public struct PostsResult: Decodable {
    let posts: [Product]
}

public struct Product: Decodable {
    let name: String
    let tagline: String
    let votes: Int
    
    //TODO: comment model
    
    //TODO: user model
    
    public struct Thumbnail: Decodable {
        let mediaType: String
        let imageUrl: URL
        let metadata: [String: String?]
        
        enum CodingKeys: String, CodingKey{
            case mediaType = "media_type"
            case imageUrl = "image_url"
            case metadata
        }
    }
    let thumbnail: Thumbnail
    
    enum CodingKeys: String, CodingKey {
        case name
        case tagline
        case votes = "votes_count"
        case thumbnail
    }
}
