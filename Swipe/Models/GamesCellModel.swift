//
//  GamesCellModel.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 15.12.2020.
//

import Foundation
import UIKit

enum GameContentType {
    case mrMrsLuvPlay
    case mrMrsLuvLeaderboard
    case mrMrsLuvGetMoreChances
    case popularityAnswer
    case popularityNewQuestion
    case popularityRating
}

enum GamesCellModel {
    
    struct Title {
        let title: String
    }
    
    struct Game {
        let title: String
        let subtitle: String
        let image: UIImage?
        let content: GameContentType
    }
    
    case title(Title)
    case top(ChatCellModel.Top)
    case game(Game)
    case text(JustTextCellModel)
}
