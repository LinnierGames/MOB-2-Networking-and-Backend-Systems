//
//  Product.swift
//  Product-Hunt
//
//  Created by Erick Sanchez on 2/2/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import UIKit

public struct PostsResult: Decodable {
    let posts: [Product]
}

public struct Product: Decodable {
    let name: String
    let tagline: String
    let votes: Int
    let thumbnail: UIImage? = nil
    
    enum CodingKeys: String, CodingKey {
        case name
        case tagline
        case votes = "votes_count"
    }
}
