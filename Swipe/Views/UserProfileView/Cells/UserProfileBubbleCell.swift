//
//  UserProfileBubbleCell.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 26.11.2020.
//

import Foundation
import UIKit

class UserProfileBubbleCell: BaseCollectionViewCell, Reusable {
    
    typealias Data = UserProfileCellModel.Bubbles
    
    private struct Sizes {
        static let horizontalOffset: CGFloat = 16
        static let verticalOffset: CGFloat = 8
        static let verticalSpacing: CGFloat = 8
        static let horizontalSpacing: CGFloat = 8
    }
    
    // MARK: - UI
    
    private lazy var mainStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = Sizes.verticalSpacing
        view.alignment = .leading
        view.distribution = .fill
        return view
    }()
    
    // MARK: - Init
    
    override func setupView() {
        super.setupView()
        backgroundColor = .clear
        setConstraints()
    }
    
    func setup(with data: UserProfileCellModel.Bubbles) {
        mainStack.arrangedSubviews.forEach({
            mainStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        
        let maxWidth = data.maxWidth - Sizes.horizontalOffset * 2
        
        var currentWidth: CGFloat = 0
        var currentViewModels: [String] = []
        
        for viewModel in data.bubbles {
            
            let elementWidth = BubbleView.size(for: viewModel,
                                               containerSize: .zero).width
            
            if currentWidth == 0, currentViewModels.count == 0 {
                currentViewModels = [viewModel]
                currentWidth = elementWidth
                continue
            }
            
            if currentWidth + elementWidth + Sizes.horizontalSpacing > maxWidth {
                
                let newStack = UIStackView(
                    arrangedSubviews: currentViewModels.compactMap({ interest in
                        let view = BubbleView(title: interest)
                        view.translatesAutoresizingMaskIntoConstraints = false
                        return view
                    })
                )
                newStack.translatesAutoresizingMaskIntoConstraints = false
                newStack.axis = .horizontal
                newStack.spacing = Sizes.horizontalSpacing
                newStack.distribution = .fill
                newStack.alignment = .center
                
                mainStack.addArrangedSubview(newStack)
                
                currentViewModels = [viewModel]
                currentWidth = elementWidth
            } else {
                currentViewModels.append(viewModel)
                
                if currentWidth == 0 {
                    currentWidth += elementWidth
                } else {
                    currentWidth += elementWidth + Sizes.horizontalSpacing
                }
            }
        }
        
        if !currentViewModels.isEmpty {
            let newStack = UIStackView(
                arrangedSubviews: currentViewModels.compactMap({ interest in
                    let view = BubbleView(title: interest)
                    view.translatesAutoresizingMaskIntoConstraints = false
                    return view
                })
            )
            
            newStack.translatesAutoresizingMaskIntoConstraints = false
            newStack.axis = .horizontal
            newStack.spacing = Sizes.horizontalSpacing
            newStack.distribution = .fill
            newStack.alignment = .center
            
            mainStack.addArrangedSubview(newStack)
            
            currentViewModels = []
            currentWidth = 0
        }
        
        setNeedsLayout()
    }
    
    static func size(for data: UserProfileCellModel.Bubbles, containerSize: CGSize) -> CGSize {
        var finalHeight: CGFloat = 0
        
        finalHeight += Sizes.verticalOffset
        
        let maxWidth = data.maxWidth - Sizes.horizontalOffset * 2
        
        var currentWidth: CGFloat = 0
        var currentViewModels: [String] = []
        
        for viewModel in data.bubbles {
            
            let elementWidth = BubbleView.size(for: viewModel,
                                               containerSize: .zero).width
            
            if currentWidth == 0, currentViewModels.count == 0 {
                currentViewModels = [viewModel]
                currentWidth = elementWidth
                continue
            }
            
            if currentWidth + elementWidth + Sizes.horizontalSpacing > maxWidth {
                
                finalHeight += Sizes.verticalSpacing
                finalHeight += BubbleView.Size.height
                
                currentViewModels = [viewModel]
                currentWidth = elementWidth
            } else {
                currentViewModels.append(viewModel)
                
                if currentWidth == 0 {
                    currentWidth += elementWidth
                } else {
                    currentWidth += elementWidth + Sizes.horizontalSpacing
                }
            }
        }
        
        if !currentViewModels.isEmpty {
            
            currentViewModels = []
            currentWidth = 0
            
            finalHeight += Sizes.verticalSpacing
            finalHeight += BubbleView.Size.height
        }
        
        finalHeight -= Sizes.verticalSpacing
        
        finalHeight += Sizes.verticalOffset
        
        return CGSize(width: containerSize.width, height: finalHeight)
    }
    
    
    // MARK: - Helpers
    
    private func setConstraints() {
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Sizes.verticalOffset),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Sizes.verticalOffset),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Sizes.horizontalOffset),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Sizes.horizontalOffset),
        ])
    }
}

extension UserProfileBubbleCell {
    
    class BubbleView: UIView {
        
        struct Size {
            static let height: CGFloat = 28
            static let horizontalOffset: CGFloat = 8
        }
        
        private lazy var titleLabel: UILabel = {
            let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            view.textColor = .white
            return view
        }()
        
        init(title: String) {
            super.init(frame: .zero)
            
            titleLabel.text = title
            
            layer.cornerRadius = 10
            backgroundColor = UIColor.luvApp.violet
            
            setConstraints()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setTitle(_ title: String?) {
            titleLabel.text = title
            layoutIfNeeded()
        }
        
        static func size(for title: String?, containerSize: CGSize) -> CGSize {
            var finalWidth: CGFloat = 0
            
            finalWidth += Size.horizontalOffset
            finalWidth += title?.width(withConstrainedHeight: Size.height,
                                       font: UIFont.systemFont(ofSize: 12, weight: .regular)) ?? 0
            finalWidth += Size.horizontalOffset
            
            return CGSize(width: finalWidth, height: Size.height)
        }
        
        private func setConstraints() {
            addSubview(titleLabel)
            
            NSLayoutConstraint.activate([
                heightAnchor.constraint(greaterThanOrEqualToConstant: Size.height),
                
                titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Size.horizontalOffset),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Size.horizontalOffset)
            ])
        }
    }
}
