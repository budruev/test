//
//  SwipeAdapter.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 26.11.2020.
//

import Foundation
import Koloda
import LuvAppCore

class SwipeAdapter: NSObject, KolodaViewDelegate, KolodaViewDataSource {
    
    private var viewModels: [UserProfile] = []
    
    private let didTapChatRequest: ValueCallback<UserProfile?>?
    private let selectionAction: ValueCallback<UserProfile>?
    private let didSwipeWithPercentage: ((_ percentage: CGFloat, _ direction: SwipeResultDirection) -> Void)?
    private let didSwipeCardAt: ((_ index: Int, _ direction: SwipeResultDirection) -> Void)?
    private let didResetCard: VoidCallback?
    private let didRanOutOfCards: VoidCallback?

    init(selectionAction: ValueCallback<UserProfile>?,
         didSwipeWithPercentage: ((_ percentage: CGFloat, _ direction: SwipeResultDirection) -> Void)?,
         didSwipeCardAt: ((_ index: Int, _ direction: SwipeResultDirection) -> Void)?,
         didResetCard: VoidCallback?,
         didRanOutOfCards: VoidCallback?,
         didTapChatRequest: ValueCallback<UserProfile?>?) {
        self.selectionAction = selectionAction
        self.didSwipeWithPercentage = didSwipeWithPercentage
        self.didSwipeCardAt = didSwipeCardAt
        self.didResetCard = didResetCard
        self.didRanOutOfCards = didRanOutOfCards
        self.didTapChatRequest = didTapChatRequest
    }
    
    func updateData(for viewModels: [UserProfile]) {
        self.viewModels = viewModels
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = UserProfileView(didTapChatRequest: didTapChatRequest)
        view.setup(with: viewModels[index], relation: .none)
        return view
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return viewModels.count
    }
    
    func koloda(_ koloda: KolodaView,
                didSwipeCardAt index: Int,
                in direction: SwipeResultDirection) {
        didSwipeCardAt?(index, direction)
    }
    
    func koloda(_ koloda: KolodaView,
                draggedCardWithPercentage finishPercentage: CGFloat,
                in direction: SwipeResultDirection) {
        didSwipeWithPercentage?(finishPercentage, direction)
    }
    
    func kolodaDidResetCard(_ koloda: KolodaView) {
        didResetCard?()
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        didRanOutOfCards?()
    }
    
    func koloda(_ koloda: KolodaView,
                allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [
            .left,
            //.topLeft,
            //.bottomLeft,
            .right,
            //.topRight,
            //.bottomRight
        ]
    }
}
