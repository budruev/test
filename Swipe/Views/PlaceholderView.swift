//
//  PlaceholderView.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 08.12.2020.
//

import Foundation
import UIKit
import RxSwift
import RxRelay

class PlaceholderView: UIView {
    
    private struct Sizes {
        static let imageSize: CGFloat = 120
        static let verticalSpacing: CGFloat = 16
        static let verticalOffset: CGFloat = 4
    }
    
    // MARK: - UI
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.rubikFont(ofSize: 24, weight: .medium)
        view.textColor = UIColor.luvApp.text
        view.numberOfLines = 0
        view.textAlignment = .center
        view.text = R.string.localizable.you_already_swiped_ten_today_title()
        return view
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.rubikFont(ofSize: 16, weight: .regular)
        view.textColor = UIColor.luvApp.lightGrayText
        view.numberOfLines = 0
        view.textAlignment = .center
        view.text = R.string.localizable.your_search_is_limited_when_not_premium_title()
        return view
    }()
    
    private lazy var startButton: StandardButton = {
        let view = StandardButton(style: .primary)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle(R.string.localizable.become_premium_title(), for: .normal)
        return view
    }()
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    func setup(didTapButton: VoidCallback?) {
        startButton.rx.tap.observeOn(MainScheduler.instance).subscribe(onNext: {
            didTapButton?()
        }).disposed(by: disposeBag)
    }
    
    func setButtonHidden(_ hidden: Bool) {
        startButton.isHidden = hidden
    }
    
    private func setConstraints() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(startButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Sizes.verticalOffset),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            startButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: Sizes.verticalSpacing),
            startButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            startButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            startButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
