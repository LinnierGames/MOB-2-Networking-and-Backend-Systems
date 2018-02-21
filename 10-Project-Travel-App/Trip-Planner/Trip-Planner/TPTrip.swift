//
//  TPTrip.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/18/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation

struct TPTrip: Codable {
    let id: String?
    var title: String
    let user: TPUser! = nil
    
    init(id: String? = nil, title: String) {
        self.id = id
        self.title = title
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
    }
}
