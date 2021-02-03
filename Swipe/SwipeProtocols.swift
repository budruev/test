//
//  SwipeProtocols.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 25.11.2020.
//

import Foundation
import LuvAppCore
import UIKit
import RxSwift

protocol SwipePresenterProtocol: AnyObject {
    func onViewDidLoad()
    func onViewDidAppear()
    func onTapFilters()
    func onBecomePremium()
    func onTapChatRequest(_ user: UserProfile?)
    func onSwipeRight(_ index: Int)
    func onSwipeLeft(_ index: Int)
    func didRanOutOfCards()
    func onSelectGameCellModel(_ cellModel: GamesCellModel)
    func onToggleSelector(_ index: Int)
}

enum SwipeState {
    case swipe
    case limited
    case loading
}

enum SwipeViewState {
    case games
    case swipe
}

protocol SwipeViewProtocol: ViewInputTraits {
    func reloadData(gamesCellModel: [GamesCellModel])
    func reloadData(viewModels: [UserProfile])
    func setSwipeState(_ state: SwipeState)
    func setButtonHidden(_ hidden: Bool)
    func setViewState(_ state: SwipeViewState)
}
