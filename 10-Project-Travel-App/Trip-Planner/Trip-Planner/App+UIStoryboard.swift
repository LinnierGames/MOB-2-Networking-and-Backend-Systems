//
//  App+UIStoryboard.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/14/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

enum TPStoryboards: String {
    case Main
    case Login
}

extension UIStoryboard {
    convenience init(storyboard: TPStoryboards) {
        self.init(name: storyboard.rawValue, bundle: Bundle.main)
    }
}
