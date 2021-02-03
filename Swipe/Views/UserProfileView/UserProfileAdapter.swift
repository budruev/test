//
//  UserProfileAdapter.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 26.11.2020.
//

import Foundation
import UIKit

class UserProfileAdapter: NSObject,
                   UICollectionViewDelegate,
                   UICollectionViewDataSource,
                   UICollectionViewDelegateFlowLayout {
    
    private var viewModels: [UserProfileCellModel] = []
    
    private let selectionAction: ValueCallback<UserProfileCellModel>?
    private let scrollViewDidScroll: VoidCallback?

    init(selectionAction: ValueCallback<UserProfileCellModel>? = nil,
         scrollViewDidScroll: VoidCallback?) {
        self.selectionAction = selectionAction
        self.scrollViewDidScroll = scrollViewDidScroll
    }
    
    func updateData(for viewModels: [UserProfileCellModel]) {
        self.viewModels = viewModels
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScroll?()
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
        case .name(let model):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileNameCell.identifier(),
                                                                for: indexPath) as? UserProfileNameCell else {
                return UICollectionViewCell()
            }
            cell.setup(with: model)
            return cell
        case .title(let model):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JustTextCell.identifier(),
                                                                for: indexPath) as? JustTextCell else {
                return UICollectionViewCell()
            }
            cell.setup(with: getJustTitleModel(for: model.title))
            return cell
        case .text(let model):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JustTextCell.identifier(),
                                                                for: indexPath) as? JustTextCell else {
                return UICollectionViewCell()
            }
            cell.setup(with: getJustTextModel(for: model.text))
            return cell
        case .bubbles(let model):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileBubbleCell.identifier(),
                                                                for: indexPath) as? UserProfileBubbleCell else {
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
        case .name(let model):
            return UserProfileNameCell.size(for: model, containerSize: containerSize)
        case .title(let model):
            return JustTextCell.size(for: getJustTitleModel(for: model.title), containerSize: containerSize)
        case .text(let model):
            return JustTextCell.size(for: getJustTextModel(for: model.text), containerSize: containerSize)
        case .bubbles(let model):
            return UserProfileBubbleCell.size(for: model, containerSize: containerSize)
        }
    }
    
    private func getJustTextModel(for text: String?) -> JustTextCellModel {
        return JustTextCellModel(
            title: text,
            textColor: UIColor.white,
            textFont: UIFont.rubikFont(ofSize: 16, weight: .regular),
            insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16),
            textAlignment: .natural
        )
    }
    
    private func getJustTitleModel(for text: String?) -> JustTextCellModel {
        return JustTextCellModel(
            title: text,
            textColor: UIColor.luvApp.darkGrayText,
            textFont: UIFont.rubikFont(ofSize: 16, weight: .regular),
            insets: UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16),
            textAlignment: .natural
        )
    }
}
