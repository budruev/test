//
//  UserProfileNameCell.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 26.11.2020.
//

import Foundation
import UIKit

class UserProfileNameCell: BaseCollectionViewCell, Reusable {
    
    typealias Data = UserProfileCellModel.Name
    
    private struct Sizes {
        static let horizontalOffset: CGFloat = 16
        static let verticalOffset: CGFloat = 4
    }
    
    // MARK: - UI
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.rubikFont(ofSize: 18, weight: .medium)
        view.textColor = .white
        view.numberOfLines = 1
        return view
    }()
    
    // MARK: - Init
    
    override func setupView() {
        super.setupView()
        backgroundColor = .clear
        setConstraints()
    }
    
    func setup(with data: UserProfileCellModel.Name) {
        titleLabel.attributedText = UserProfileNameCell.getAttrString(data: data)
    }
    
    static func size(for data: UserProfileCellModel.Name, containerSize: CGSize) -> CGSize {
        var height: CGFloat = 0
        
        height += Sizes.verticalOffset
        height += getAttrString(data: data)
            .height(withConstrainedWidth: containerSize.width - Sizes.horizontalOffset * 2)
        height += Sizes.verticalOffset
        
        return CGSize(width: containerSize.width, height: height)
    }
    
    // MARK: - Helpers
    
    private static func getAttrString(data: UserProfileCellModel.Name) -> NSAttributedString {
        let string = (data.name ?? "") + ", " + (data.age ?? "")
        let mutableString = NSMutableAttributedString(
            string: string,
            attributes: [
                .foregroundColor: UIColor.white,
                .font: UIFont.rubikFont(ofSize: 24, weight: .regular)
            ]
        )
        
        mutableString.addAttribute(
            .font,
            value: UIFont.rubikFont(ofSize: 24, weight: .medium),
            range: (string as NSString).range(of: data.name ?? "")
        )
        
        return mutableString
    }
    
    private func setConstraints() {
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Sizes.verticalOffset),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Sizes.horizontalOffset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Sizes.horizontalOffset),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Sizes.verticalOffset)
        ])
    }
}
