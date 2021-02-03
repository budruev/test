//
//  UserProfileView.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 26.11.2020.
//

import Foundation
import UIKit
import LuvAppCore
import RxSwift
import RxCocoa

class UserProfileView: UIView {
    
    private struct Sizes {
        static let userImageSize: CGFloat = 0.8
        static let collectionInset: CGFloat = 60
        static let collectionBottomInset: CGFloat = 16
        static let chatRequestInset: CGFloat = 16
    }
    
    // MARK: - UI
    
    private lazy var userImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var gradientImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleToFill
        view.image = R.image.gradients.viewGradient()?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .black
        return view
    }()
    
    private lazy var scrollIndicatorView: UserCardScrollIndicatorView = {
        let view = UserCardScrollIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.delaysContentTouches = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.contentInset.bottom = Sizes.collectionBottomInset
        return view
    }()
    
    private lazy var chatRequestGradientImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleToFill
        view.image = R.image.gradients.viewGradient()?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .black
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }()
    
    private lazy var chatRequestButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(R.image.icons.chatRequest(), for: .normal)
        return view
    }()
    
    private lazy var relationshipTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.rubikFont(ofSize: 18, weight: .medium)
        view.textColor = .white
        view.numberOfLines = 1
        return view
    }()
    
    // MARK: - Properties
    
    private let didTapChatRequest: ValueCallback<UserProfile?>?
    
    private lazy var adapter = UserProfileAdapter { [weak self] model in
        //self?.presenter.onSelectCellModel(model)
    } scrollViewDidScroll: { [weak self] in
        self?.scrollViewDidScroll()
    }
    
    private var model: UserProfile?
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(didTapChatRequest: ValueCallback<UserProfile?>?) {
        self.didTapChatRequest = didTapChatRequest
        
        super.init(frame: .zero)
        
        collectionView.delegate = adapter
        collectionView.dataSource = adapter
        
        collectionView.register(UserProfileBubbleCell.self, forCellWithReuseIdentifier: UserProfileBubbleCell.identifier())
        collectionView.register(JustTextCell.self, forCellWithReuseIdentifier: JustTextCell.identifier())
        collectionView.register(UserProfileNameCell.self, forCellWithReuseIdentifier: UserProfileNameCell.identifier())
        
        clipsToBounds = true
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.luvApp.violet.cgColor
        backgroundColor = .black
        setConstraints()
        
        chatRequestButton.rx.tap.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in
            self?.didTapChatRequest?(self?.model)
        }).disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private let localImageStorageService = LocalImageStorageService()
    
    private func scrollViewDidScroll() {
        var position = (collectionView.contentOffset.y + collectionView.contentInset.top) /
            (collectionView.contentSize.height - collectionView.contentInset.bottom)
        print(position)
        if position < 0 {
            position = 0
        }
        if position > 1 {
            position = 1
        }
        
        UIView.performWithoutAnimation {
            self.scrollIndicatorView.setPosition(position)
        }
        
//        if showButtons {
//            if scrollView.contentOffset.y > 30, buttonsHidden {
//
//                showButtonsAnimated()
//
//            } else if scrollView.contentOffset.y < 30, !buttonsHidden {
//
//                hideButtonsAnimated()
//            }
//        }
    }
    
    func setup(with model: UserProfile, relation: UserProfileLike) {
        self.model = model
        
        userImageView.image = model.photo
        if let photoUrl = model.photoUrl {
            localImageStorageService.loadImageForUrl(photoUrl) { [weak self] image in
                DispatchQueue.main.async {
                    self?.userImageView.image = image
                }
            }
        }
        
        switch relation {
        case .likeMe:
            chatRequestButton.isHidden = false
            relationshipTitle.text = R.string.localizable.likes_title()
        case .iLike:
            chatRequestButton.isHidden = true
            relationshipTitle.text = R.string.localizable.my_likes_title()
        case .match:
            chatRequestButton.isHidden = true
            relationshipTitle.text = R.string.localizable.matches_title()
        case .none:
            chatRequestButton.isHidden = false
            relationshipTitle.text = nil
        }
        
        resetCellModels()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.contentInset.bottom = Sizes.collectionBottomInset + chatRequestGradientImageView.frame.height
        collectionView.contentInset.top = frame.height * Sizes.userImageSize - Sizes.collectionInset
        resetCellModels()
    }
    
    private func resetCellModels() {
        guard let model = model else { return }
        
        var cellModels: [UserProfileCellModel] = []
        
        cellModels.append(
            .name(
                UserProfileCellModel.Name(name: model.name,
                                          age: "\(model.age)")
            )
        )
        
        var bubbles: [String] = []
        
        bubbles.append(
            EditProfileItem.gender.emoji + " " + model.gender.title
        )
        
        bubbles.append(
            EditProfileItem.lookingFor.emoji + " " + model.lookingFor.title
        )
        
        if let pets = model.pets {
            bubbles.append(
                EditProfileItem.pets.emoji + " " + pets.title
            )
        }
        
        if let alcohol = model.alcohol {
            bubbles.append(
                EditProfileItem.alcohol.emoji + " " + alcohol.title
            )
        }
        
        if let diet = model.diet {
            bubbles.append(
                EditProfileItem.diet.emoji + " " + diet.title
            )
        }
        
        if let ethnicity = model.ethnicity {
            bubbles.append(
                EditProfileItem.ethnicity.emoji + " " + ethnicity.title
            )
        }
        
        if let kids = model.kids {
            bubbles.append(
                EditProfileItem.kids.emoji + " " + kids.title
            )
        }
        
        if let myBodyType = model.myBodyType {
            bubbles.append(
                EditProfileItem.bodyType.emoji + " " + myBodyType.title
            )
        }
        
        if let smoking = model.smoking {
            bubbles.append(
                EditProfileItem.smoking.emoji + " " + smoking.title
            )
        }
        
        if !bubbles.isEmpty {
            cellModels.append(
                .bubbles(
                    UserProfileCellModel.Bubbles(
                        bubbles: bubbles,
                        maxWidth: frame.width
                    )
                )
            )
        }
        
        if let aboutMe = model.aboutMe {
            cellModels.append(
                .title(
                    UserProfileCellModel.Title(title: R.string.localizable.about_me_title())
                )
            )
            
            cellModels.append(
                .text(
                    UserProfileCellModel.Text(text: aboutMe)
                )
            )
        }
        
        if let occupation = model.occupation {
            cellModels.append(
                .title(
                    UserProfileCellModel.Title(title: R.string.localizable.occupation_title())
                )
            )
            
            cellModels.append(
                .text(
                    UserProfileCellModel.Text(text: occupation)
                )
            )
        }
        
        if let education = model.education {
            cellModels.append(
                .title(
                    UserProfileCellModel.Title(title: R.string.localizable.education_title())
                )
            )
            
            cellModels.append(
                .text(
                    UserProfileCellModel.Text(text: education)
                )
            )
        }
        
        if let religion = model.religion {
            cellModels.append(
                .title(
                    UserProfileCellModel.Title(title: R.string.localizable.religion_title())
                )
            )
            
            cellModels.append(
                .text(
                    UserProfileCellModel.Text(text: religion)
                )
            )
        }
        
        adapter.updateData(for: cellModels)
        collectionView.reloadData()
    }
    
    private func setConstraints() {
        addSubview(userImageView)
        addSubview(gradientImageView)
        addSubview(collectionView)
        addSubview(chatRequestGradientImageView)
        addSubview(chatRequestButton)
        addSubview(scrollIndicatorView)
        addSubview(relationshipTitle)
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: topAnchor),
            userImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            userImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            userImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: Sizes.userImageSize),
            
            gradientImageView.topAnchor.constraint(equalTo: userImageView.topAnchor),
            gradientImageView.leadingAnchor.constraint(equalTo: userImageView.leadingAnchor),
            gradientImageView.trailingAnchor.constraint(equalTo: userImageView.trailingAnchor),
            gradientImageView.bottomAnchor.constraint(equalTo: userImageView.bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: userImageView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: userImageView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: userImageView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            chatRequestGradientImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            chatRequestGradientImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chatRequestGradientImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            chatRequestGradientImageView.topAnchor.constraint(equalTo: chatRequestButton.topAnchor, constant: -Sizes.chatRequestInset),
            
            chatRequestButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Sizes.chatRequestInset),
            chatRequestButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Sizes.chatRequestInset),
            
            scrollIndicatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            scrollIndicatorView.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 30),
            
            relationshipTitle.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            relationshipTitle.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -12)
        ])
    }
}
