//
//  UserProfileCellModel.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 26.11.2020.
//

import Foundation
import UIKit

enum UserProfileCellModel {
    
    struct Name {
        let name: String?
        let age: String?
    }
    
    struct Title {
        let title: String?
    }
    
    struct Text {
        let text: String?
    }
    
    struct Bubbles {
        let bubbles: [String]
        let maxWidth: CGFloat
    }
    
    case name(Name)
    case title(Title)
    case text(Text)
    case bubbles(Bubbles)
}
