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
    public struct Comment: Decodable {
        
    }
    //let comments: [Comment]
    
    let commentCount: Int
    
    public struct User: Decodable {
        let name: String
        let username: String
        let headline: String?
        
        public struct Images: Decodable {
            let original: String
        }
        let profileImages: Images
        
        enum CodingKeys: String, CodingKey {
            case name
            case username
            case headline
            case profileImages = "image_url"
        }
    }
    let user: User
    
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
        case commentCount = "comments_count"
        case user
    }
}
