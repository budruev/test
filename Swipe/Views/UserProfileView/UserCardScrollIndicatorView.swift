//
//  UserCardScrollIndicatorView.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 27.11.2020.
//

import Foundation
import UIKit

class UserCardScrollIndicatorView: UIView {
    
    private lazy var bottomScrollIndicator: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = R.image.icons.userCardBottomScrollIndicator()
        return view
    }()
    
    private lazy var topScrollIndicator: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = R.image.icons.userCardTopScrollIndicator()
        return view
    }()
    
    private var topScrollIndicatorConstraint = NSLayoutConstraint()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .clear
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPosition(_ position: CGFloat) {
        topScrollIndicatorConstraint.constant = position*(bottomScrollIndicator.frame.height - topScrollIndicator.frame.height)
    }
    
    private func setConstraints() {
        addSubview(bottomScrollIndicator)
        addSubview(topScrollIndicator)
        
        topScrollIndicatorConstraint = topScrollIndicator.topAnchor.constraint(equalTo: bottomScrollIndicator.topAnchor)
        topScrollIndicatorConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            bottomScrollIndicator.topAnchor.constraint(equalTo: topAnchor),
            bottomScrollIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomScrollIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomScrollIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            topScrollIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            topScrollIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            topScrollIndicatorConstraint
        ])
    }
}
