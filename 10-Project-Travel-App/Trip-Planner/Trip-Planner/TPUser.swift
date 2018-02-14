//
//  User.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/14/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation
import UIKit

struct TPUser: Codable {
    let username: String
    let email: String
    let thumbnail: String
    //let thumbnailImage: UIImage? = nil
    
    enum CodingKeys: String, CodingKey {
        case username
        case email
        case thumbnail
    }
}
