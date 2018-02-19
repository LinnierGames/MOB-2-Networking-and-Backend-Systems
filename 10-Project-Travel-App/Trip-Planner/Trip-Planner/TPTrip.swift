//
//  TPTrip.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/18/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import Foundation

struct TPTrip: Codable {
    var title: String
    let user: TPUser! = nil
    
    enum CodingKeys: String, CodingKey {
        case title
    }
}
