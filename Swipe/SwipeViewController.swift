//
//  SwipeViewController.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 25.11.2020.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import LuvAppCore
import Koloda

final class SwipeViewController: UIViewController {
    
    private struct Sizes {
        static let titleBottomOffset: CGFloat = 30
        static let verticalOffset: CGFloat = 16
        static let horizontalOffset: CGFloat = 16
        static let largeHorizontalOffset: CGFloat = 24
        static let maxWidth: CGFloat = 500
        static let likeButtonSize: CGFloat = 80
    }
    
    // MARK: - UI
    
    private lazy var gradientImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = R.image.gradients.topToBottomViewGradient()?.withRenderingMode(.alwaysTemplate)
        view.tintColor = UIColor.luvApp.background
        view.contentMode = .scaleToFill
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }()
    
    private lazy var swipeHolder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.luvApp.background
        return view
    }()
    
    private lazy var gamesCollectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        return layout
    }()
    
    private lazy var gamesCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: gamesCollectionViewLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.delaysContentTouches = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl(items: ["Games", "Swipe"].compactMap({ $0 }))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.selectedSegmentTintColor = UIColor.luvApp.violet
        view.backgroundColor = UIColor.luvApp.background
        view.selectedSegmentIndex = 0
        view.layer.shadowColor = UIColor.luvApp.shadow.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.25
        view.tintColor = UIColor.luvApp.text
        view.rx.selectedSegmentIndex.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] index in
            self?.presenter.onToggleSelector(index)
        }).disposed(by: disposeBag)
        return view
    }()
    
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.luvApp.text
        view.alpha = 0.2
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    private lazy var placeholderView: PlaceholderView = {
        let view = PlaceholderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setup { [weak self] in
            self?.presenter.onBecomePremium()
        }
        view.isHidden = true
        return view
    }()
    
    private lazy var kolodaView: KolodaView = {
        let view = KolodaView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var likeImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = R.image.icons.like()
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()
    
    private lazy var dislikeImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = R.image.icons.dislike()
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()
    
    private lazy var filtersButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(R.image.icons.filter()?.withRenderingMode(.alwaysTemplate), for: .normal)
        view.tintColor = UIColor.luvApp.text
        return view
    }()
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    private let presenter: SwipePresenterProtocol
    
    private lazy var adapter = SwipeAdapter { profile in
        return
    } didSwipeWithPercentage: { [weak self] (percentage, direction) in
        self?.didSwipeWithPercentage(percentage: percentage, direction: direction)
    } didSwipeCardAt: { [weak self] (index, direction) in
        self?.didSwipeCard(index: index, direction: direction)
    } didResetCard: { [weak self] in
        self?.didResetCard()
    } didRanOutOfCards: { [weak self] in
        self?.didRanOutOfCards()
    } didTapChatRequest: { [weak self] user in
        self?.presenter.onTapChatRequest(user)
        self?.kolodaView.swipe(.right)
    }
    
    private lazy var gamesAdapter = GamesAdapter { [weak self] gameCellModel in
        self?.presenter.onSelectGameCellModel(gameCellModel)
    }

    // MARK: - Init
    
    init(presenter: SwipePresenterProtocol) {
        self.presenter = presenter

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gamesCollectionView.delegate = gamesAdapter
        gamesCollectionView.dataSource = gamesAdapter
        gamesCollectionView.register(GameTitleCell.self, forCellWithReuseIdentifier: GameTitleCell.identifier())
        gamesCollectionView.register(ChatTopCell.self, forCellWithReuseIdentifier: ChatTopCell.identifier())
        gamesCollectionView.register(JustTextCell.self, forCellWithReuseIdentifier: JustTextCell.identifier())
        
        kolodaView.delegate = adapter
        kolodaView.dataSource = adapter
        
        view.backgroundColor = UIColor.luvApp.background
        
        navigationItem.configureWithInlineDisplayMode(title: nil, navigationBarAppearance: .transparentAppearance())
        navigationItem.titleView = segmentedControl
        
        filtersButton.rx.tap.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] in
            self?.presenter.onTapFilters()
        }).disposed(by: disposeBag)
        
        setConstraints()
        
        presenter.onViewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.onViewDidAppear()
        
        animateLoading()
    }
    
    // MARK: - Helpers
    
    private func didSwipeWithPercentage(percentage: CGFloat,
                                        direction: SwipeResultDirection) {
        guard percentage > 96  else {
            likeImageView.isHidden = true
            dislikeImageView.isHidden = true
            return
        }
        
        switch direction {
        case .left, .topLeft, .bottomLeft:
            dislikeImageView.isHidden = false
            likeImageView.isHidden = true
        default:
            dislikeImageView.isHidden = true
            likeImageView.isHidden = false
        }
    }
    
    private func didSwipeCard(index: Int,
                              direction: SwipeResultDirection) {
        dislikeImageView.isHidden = true
        likeImageView.isHidden = true
        switch direction {
        case .left, .topLeft, .bottomLeft:
            presenter.onSwipeLeft(index)
        case .right, .topRight, .bottomRight:
            presenter.onSwipeRight(index)
        default:
            break
        }
    }
    
    private func didResetCard() {
        dislikeImageView.isHidden = true
        likeImageView.isHidden = true
    }
    
    private func didRanOutOfCards() {
        presenter.didRanOutOfCards()
    }
    
    private func setConstraints() {
        view.addSubview(gamesCollectionView)
        view.addSubview(swipeHolder)
        swipeHolder.addSubview(loadingView)
        swipeHolder.addSubview(kolodaView)
        swipeHolder.addSubview(placeholderView)
        swipeHolder.addSubview(likeImageView)
        swipeHolder.addSubview(dislikeImageView)
        view.addSubview(gradientImageView)
        
        if UIScreen.isIpad {
            NSLayoutConstraint.activate([
                kolodaView.widthAnchor.constraint(equalToConstant: Sizes.maxWidth),
                kolodaView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                gamesCollectionView.widthAnchor.constraint(equalToConstant: Sizes.maxWidth),
                gamesCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                kolodaView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Sizes.horizontalOffset),
                kolodaView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Sizes.horizontalOffset),
                
                gamesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                gamesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        NSLayoutConstraint.activate([
            gradientImageView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            gradientImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            swipeHolder.topAnchor.constraint(equalTo: view.topAnchor),
            swipeHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            swipeHolder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            swipeHolder.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            gamesCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            gamesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            kolodaView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            kolodaView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Sizes.verticalOffset),
            
            loadingView.topAnchor.constraint(equalTo: kolodaView.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: kolodaView.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: kolodaView.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: kolodaView.bottomAnchor),
            
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: kolodaView.leadingAnchor, constant: Sizes.horizontalOffset),
            placeholderView.trailingAnchor.constraint(equalTo: kolodaView.trailingAnchor, constant: -Sizes.horizontalOffset),
            
            likeImageView.topAnchor.constraint(equalTo: kolodaView.topAnchor),
            likeImageView.leadingAnchor.constraint(equalTo: kolodaView.leadingAnchor),
            likeImageView.heightAnchor.constraint(equalToConstant: Sizes.likeButtonSize),
            likeImageView.widthAnchor.constraint(equalToConstant: Sizes.likeButtonSize),
            
            dislikeImageView.topAnchor.constraint(equalTo: kolodaView.topAnchor),
            dislikeImageView.trailingAnchor.constraint(equalTo: kolodaView.trailingAnchor),
            dislikeImageView.heightAnchor.constraint(equalToConstant: Sizes.likeButtonSize),
            dislikeImageView.widthAnchor.constraint(equalToConstant: Sizes.likeButtonSize),
            
            filtersButton.heightAnchor.constraint(equalToConstant: 24),
            filtersButton.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
}

// MARK: - SwipeViewProtocol

extension SwipeViewController: SwipeViewProtocol {
    func reloadData(viewModels: [UserProfile]) {
        adapter.updateData(for: viewModels)
        kolodaView.reloadData()
    }
    
    func setSwipeState(_ state: SwipeState) {
        switch state {
        case .limited:
            placeholderView.isHidden = false
            loadingView.isHidden = true
        case .loading:
            placeholderView.isHidden = true
            loadingView.isHidden = false
        case .swipe:
            loadingView.isHidden = true
            placeholderView.isHidden = true
        }
    }
    
    func setButtonHidden(_ hidden: Bool) {
        placeholderView.setButtonHidden(hidden)
    }
    
    private func animateLoading() {
        loadingView.layer.removeAllAnimations()
        loadingView.alpha = 0.2
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: [.repeat],
                       animations: { [weak self] in
                        self?.loadingView.alpha = 0
        }) { [weak self] finished in
            self?.loadingView.alpha = 0.2
        }
    }
    
    func reloadData(gamesCellModel: [GamesCellModel]) {
        gamesAdapter.updateData(for: gamesCellModel)
        gamesCollectionView.reloadData()
    }
    
    func setViewState(_ state: SwipeViewState) {
        switch state {
        case .games:
            gamesCollectionView.isHidden = false
            swipeHolder.isHidden = true
            navigationItem.rightBarButtonItem = nil
        case .swipe:
            gamesCollectionView.isHidden = true
            swipeHolder.isHidden = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filtersButton)
        }
    }
}
