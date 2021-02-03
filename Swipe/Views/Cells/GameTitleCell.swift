//
//  GameTitleCell.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 15.12.2020.
//

import Foundation
import UIKit

class GameTitleCell: BaseCollectionViewCell, Reusable {
    
    typealias Data = GamesCellModel.Game
    
    private struct Sizes {
        static let imageSize: CGFloat = 34
        static let horizontalOffset: CGFloat = 16
        static let verticalOffset: CGFloat = 8
        static let verticalSpacing: CGFloat = 12
        static let horizontalSpacing: CGFloat = 12
        static let textVerticalSpacing: CGFloat = 2
    }
    
    // MARK: - UI
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.backgroundColor = UIColor.luvApp.violet
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.font = UIFont.rubikFont(ofSize: 18, weight: .medium)
        view.numberOfLines = 0
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.font = UIFont.rubikFont(ofSize: 16, weight: .regular)
        view.numberOfLines = 0
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    
    // MARK: - Init
    
    override func setupView() {
        super.setupView()
        isShrinking = true
        backgroundColor = .clear
        setConstraints()
    }
    
    func setup(with data: GamesCellModel.Game) {
        iconImageView.image = data.image
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
        
//        switch data.content {
//        case .mrMrsLuvPlay:
//            cardView.backgroundColor = .systemRed
//        case .mrMrsLuvLeaderboard:
//            cardView.backgroundColor = .systemOrange
//        case .mrMrsLuvGetMoreChances:
//            cardView.backgroundColor = UIColor.luvApp.violet
//        case .popularityAnswer:
//            cardView.backgroundColor = .systemRed
//        case .popularityNewQuestion:
//            cardView.backgroundColor = .systemGreen
//        case .popularityRating:
//            cardView.backgroundColor = .systemOrange
//        }
    }
    
    static func size(for data: GamesCellModel.Game, containerSize: CGSize) -> CGSize {
        var height: CGFloat = 0
        
        height += Sizes.verticalOffset
        
        let leftHeight = Sizes.verticalSpacing + Sizes.verticalSpacing + Sizes.imageSize
        
        var rightHeight = Sizes.verticalSpacing + Sizes.verticalSpacing + Sizes.textVerticalSpacing
        let maxTextWidth = containerSize.width - Sizes.horizontalOffset * 4 - Sizes.horizontalSpacing - Sizes.imageSize
        
        rightHeight += data.title.height(withConstrainedWidth: maxTextWidth,
                                         font: UIFont.rubikFont(ofSize: 18, weight: .medium))
        rightHeight += data.subtitle.height(withConstrainedWidth: maxTextWidth,
                                            font: UIFont.rubikFont(ofSize: 16, weight: .regular))
        
        height += max(leftHeight, rightHeight)
        
        height += Sizes.verticalOffset
        
        return CGSize(width: containerSize.width, height: height)
    }
    
    // MARK: - Helpers
    
    private func setConstraints() {
        contentView.addSubview(cardView)
        cardView.addSubview(iconImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Sizes.verticalOffset),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Sizes.verticalOffset),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Sizes.horizontalOffset),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Sizes.horizontalOffset),
            
            iconImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: Sizes.horizontalOffset),
            iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: Sizes.imageSize),
            iconImageView.widthAnchor.constraint(equalToConstant: Sizes.imageSize),
            iconImageView.topAnchor.constraint(greaterThanOrEqualTo: cardView.topAnchor, constant: Sizes.verticalSpacing),
            iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -Sizes.verticalSpacing),
            
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: cardView.topAnchor, constant: Sizes.verticalSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Sizes.horizontalSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Sizes.horizontalOffset),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Sizes.textVerticalSpacing),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -Sizes.horizontalOffset),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -Sizes.verticalSpacing)
        ])
    }
}
