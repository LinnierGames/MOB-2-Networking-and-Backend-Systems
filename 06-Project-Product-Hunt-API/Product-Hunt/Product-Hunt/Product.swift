//
//  Product.swift
//  Product-Hunt
//
//  Created by Erick Sanchez on 2/2/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import UIKit

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

//TODO: use swifty json to remove the nested container from a network call
public struct PostsResult: Decodable {
    let posts: [Product]
}

public class Product: Decodable {
    let id: Int
    let name: String
    let tagline: String
    let votes: Int
    
    private var _comments: [CommentsResult.Comment]? = nil
    public func comments(complition: @escaping ([CommentsResult.Comment]?) -> ()) {
        if let comments = _comments {
            complition(comments)
        } else {
            ProductNetworkService.fetchComments(for: self, resultHandler: { (result) in
                switch result {
                case .Success(let comments):
                    self._comments = comments
                    
                    return complition(comments)
                case .Failed(let message):
                    print(message)
                    
                    return complition(nil)
                }
            })
        }
    }
    
    let commentCount: Int
    
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
        case id
        case name
        case tagline
        case votes = "votes_count"
        case thumbnail
        case commentCount = "comments_count"
        case user
    }
}


public struct CommentsResult: Decodable {
    
    public struct Comment: Decodable {
        let id: Int
        let body: String
        let createdAt: String
        let votes: Int
        var user: User
        
        enum CodingKeys: String, CodingKey {
            case id
            case body
            case createdAt = "created_at"
            case votes
            case user
        }
    }
    let comments: [Comment]
}
