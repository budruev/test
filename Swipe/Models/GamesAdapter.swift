//
//  GamesAdapter.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 15.12.2020.
//

import Foundation
import UIKit

class GamesAdapter: NSObject,
                   UICollectionViewDelegate,
                   UICollectionViewDataSource,
                   UICollectionViewDelegateFlowLayout {
    
    private var viewModels: [GamesCellModel] = []
    
    private let selectionAction: ValueCallback<GamesCellModel>?

    init(selectionAction: ValueCallback<GamesCellModel>? = nil) {
        self.selectionAction = selectionAction
    }
    
    func updateData(for viewModels: [GamesCellModel]) {
        self.viewModels = viewModels
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectionAction?(viewModels[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = viewModels[indexPath.row]
        
        switch viewModel {
        case .title(let model):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JustTextCell.identifier(),
                                                                for: indexPath) as? JustTextCell else {
                return UICollectionViewCell()
            }
            cell.setup(with: getJustTextModel(for: model.title))
            return cell
        case .top(let model):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatTopCell.identifier(),
                                                                for: indexPath) as? ChatTopCell else {
                return UICollectionViewCell()
            }
            cell.setup(with: model)
            return cell
        case .game(let model):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GameTitleCell.identifier(),
                                                                for: indexPath) as? GameTitleCell else {
                return UICollectionViewCell()
            }
            cell.setup(with: model)
            return cell
        case .text(let model):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JustTextCell.identifier(),
                                                                for: indexPath) as? JustTextCell else {
                return UICollectionViewCell()
            }
            cell.setup(with: model)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = viewModels[indexPath.row]
        
        let width = collectionView.frame.width
        let containerSize = CGSize(width: width,
                                   height: .greatestFiniteMagnitude)
        
        switch viewModel {
        case .text(let model):
            return JustTextCell.size(for: model, containerSize: containerSize)
        case .title(let model):
            return JustTextCell.size(for: getJustTextModel(for: model.title), containerSize: containerSize)
        case .top(let model):
            return ChatTopCell.size(for: model,
                                    containerSize: containerSize)
        case .game(let model):
            return GameTitleCell.size(for: model, containerSize: containerSize)
        }
    }
    
    private func getJustTextModel(for text: String) -> JustTextCellModel {
        return JustTextCellModel(
            title: text,
            textColor: UIColor.luvApp.text,
            textFont: UIFont.rubikFont(ofSize: 18, weight: .medium),
            insets: UIEdgeInsets(x: 16, y: 8),
            textAlignment: .natural
        )
    }
}
