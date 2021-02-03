//
//  SwipePresenter.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 25.11.2020.
//

import Foundation
import LuvAppCore
import RxSwift

final class SwipePresenter {
    
    weak var view: SwipeViewProtocol?
    private weak var moduleOutput: SwipeModuleOutput? = nil
    
    private let analyticsService: EventsLoggerServiceProtocol
    private let subscriptionManager: SubscriptionManagerProtocol
    private let swipeManager: SwipeManagerProtocol
    private let storageManager: StorageServiceProtocol
    private let accountManager: AccountManager
    
    private var usersToSwipe: [UserProfile] = []
    private var chatRequestedUsers: [UserProfile] = []
    
    private var viewState: SwipeViewState = .games
    
    private let disposeBag = DisposeBag()
    
    init(moduleOutput: SwipeModuleOutput? = nil,
         analyticsService: EventsLoggerServiceProtocol,
         subscriptionManager: SubscriptionManagerProtocol,
         swipeManager: SwipeManagerProtocol,
         appStateManager: AppStateManagerService,
         storageManager: StorageServiceProtocol,
         accountManager: AccountManager) {
        self.moduleOutput = moduleOutput
        self.analyticsService = analyticsService
        self.subscriptionManager = subscriptionManager
        self.swipeManager = swipeManager
        self.storageManager = storageManager
        self.accountManager = accountManager
        
        subscriptionManager.isSubscriptionActive.subscribe(onNext: { [weak self] isPremium in
            self?.view?.setButtonHidden(isPremium)
        }).disposed(by: disposeBag)
        
        swipeManager.swipeRelay.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] newUsers in
            guard let self = self else {
                return
            }
            
            if self.usersToSwipe != newUsers {
                self.usersToSwipe = newUsers
                self.profilesUpdated()
            }
            
        }).disposed(by: disposeBag)
    }
}

// MARK: - SwipePresenterProtocol

extension SwipePresenter: SwipePresenterProtocol {
    func onViewDidLoad() {
        view?.setViewState(viewState)
        updateGamesData()
        updateData()
        view?.setButtonHidden(subscriptionManager.isPremium)
    }
    
    func onToggleSelector(_ index: Int) {
        if index == 0 {
            viewState = .games
        } else {
            viewState = .swipe
        }
        view?.setViewState(viewState)
    }
    
    func onSelectGameCellModel(_ cellModel: GamesCellModel) {
        switch cellModel {
        case .game(let model):
            moduleOutput?.swipeModuleDidSelectGame(self, gameContent: model.content)
        default:
            break
        }
    }
    
    private func updateData() {
        view?.setSwipeState(.loading)
        swipeManager.getTenSwipeProfiles { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let profiles):
                if self.usersToSwipe != profiles {
                    self.usersToSwipe = profiles
                    DispatchQueue.main.async {
                        self.profilesUpdated()
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    private func profilesUpdated() {
        if usersToSwipe.isEmpty || storageManager.todaySwipesCount >= 10 {
            view?.setSwipeState(.limited)
            view?.reloadData(viewModels: [])
        } else {
            view?.setSwipeState(.swipe)
            view?.reloadData(viewModels: usersToSwipe)
        }
    }
    
    private func updateGamesData() {
        var cellModels: [GamesCellModel] = []
        
        cellModels.append(
            .top(
                ChatCellModel.Top(
                    title: R.string.localizable.games_title(),
                    rightButtonImage: nil,
                    rightButtonAction: {
                        return
                    }
                )
            )
        )
        
        cellModels.append(
            .title(
                GamesCellModel.Title(title: R.string.localizable.mr_and_mrs_luv_title())
            )
        )
        
        cellModels.append(
            .game(
                GamesCellModel.Game(
                    title: R.string.localizable.choose_today_ten_winners_title(),
                    subtitle: R.string.localizable.every_shoosen_user_gets_one_to_rating(),
                    image: R.image.games.chooseStar(),
                    content: .mrMrsLuvPlay
                )
            )
        )
        
        cellModels.append(
            .game(
                GamesCellModel.Game(
                    title: R.string.localizable.check_leaderboard_title(),
                    subtitle: R.string.localizable.who_is_mr_and_mrs_luv_now(),
                    image: R.image.games.starBranch(),
                    content: .mrMrsLuvLeaderboard
                )
            )
        )
        
        if !subscriptionManager.isPremium {
            cellModels.append(
                .game(
                    GamesCellModel.Game(
                        title: R.string.localizable.get_more_chances_title(),
                        subtitle: R.string.localizable.you_will_be_shown_10_more_times(),
                        image: R.image.icons.premium(),
                        content: .mrMrsLuvGetMoreChances
                    )
                )
            )
        }
        
        cellModels.append(
            .title(
                GamesCellModel.Title(title: R.string.localizable.popularity_game_title())
            )
        )
        
        cellModels.append(
            .game(
                GamesCellModel.Game(
                    title: R.string.localizable.answer_new_random_question(),
                    subtitle: R.string.localizable.you_could_answer_ten_questions_every_day(),
                    image: R.image.games.starFireworks(),
                    content: .popularityAnswer
                )
            )
        )
        
        cellModels.append(
            .game(
                GamesCellModel.Game(
                    title: R.string.localizable.create_new_question(),
                    subtitle: R.string.localizable.other_users_will_choose_who_is_the_answer(),
                    image: R.image.games.addQuestion(),
                    content: .popularityNewQuestion
                )
            )
        )
        
        cellModels.append(
            .game(
                GamesCellModel.Game(
                    title: R.string.localizable.total_rating_title(),
                    subtitle: R.string.localizable.who_was_choosen_as_answer_more_times(),
                    image: R.image.games.starPodium(),
                    content: .popularityRating
                )
            )
        )
        
        cellModels.append(
            .text(
                JustTextCellModel(
                    title: R.string.localizable.new_games_are_coming_title(),
                    textColor: UIColor.luvApp.lightGrayText,
                    textFont: UIFont.rubikFont(ofSize: 14, weight: .regular),
                    insets: UIEdgeInsets(x: 16, y: 8),
                    textAlignment: .center
                )
            )
        )
        
        view?.reloadData(gamesCellModel: cellModels)
    }
    
    func onViewDidAppear() {
        analyticsService.logEvent("Swipes_Apear")
    }
    
    func onSwipeRight(_ index: Int) {
        analyticsService.logEvent("Swipes_Swipe_Like")
        
        if storageManager.todaySwipesCount >= 10, !subscriptionManager.isPremium {
            view?.setSwipeState(.limited)
            view?.reloadData(viewModels: [])
            moduleOutput?.swipeModuleDidSelectPaywall(self)
            return
        }
        
        guard usersToSwipe.count > index else {
            return
        }
        
        let user = usersToSwipe[index]
        usersToSwipe.remove(at: index)
        guard !chatRequestedUsers.contains(where: { $0.id == user.id }) else {
            return
        }
        
        swipeManager.sendSwipeActionTo(user, action: .like)
        checkMatchAvailable(user)
    }
    
    func onSwipeLeft(_ index: Int) {
        analyticsService.logEvent("Swipes_Swipe_Dislike")
        
        if storageManager.todaySwipesCount >= 10, !subscriptionManager.isPremium {
            view?.setSwipeState(.limited)
            view?.reloadData(viewModels: [])
            moduleOutput?.swipeModuleDidSelectPaywall(self)
            return
        }
        
        guard usersToSwipe.count > index else {
            return
        }
        
        let user = usersToSwipe[index]
        usersToSwipe.remove(at: index)
        guard !chatRequestedUsers.contains(where: { $0.id == user.id }) else {
            return
        }
        
        swipeManager.sendSwipeActionTo(user, action: .dislike)
    }
    
    func didRanOutOfCards() {
        analyticsService.logEvent("Swipes_Out_Of_Cards")
        view?.setSwipeState(.limited)
    }
    
    func onTapChatRequest(_ user: UserProfile?) {
        analyticsService.logEvent("Swipes_Tap_ChatRequest")
        
        if storageManager.todaySwipesCount >= 10, !subscriptionManager.isPremium {
            view?.setSwipeState(.limited)
            view?.reloadData(viewModels: [])
            moduleOutput?.swipeModuleDidSelectPaywall(self)
            return
        }
        
        guard let user = user else {
            return
        }
        
        if let index = usersToSwipe.firstIndex(where: { $0.id == user.id }) {
            usersToSwipe.remove(at: index)
        }
        
        chatRequestedUsers.append(user)
        //SnackBar(text: "-1 Chat Request", style: .error).show()
        //swipeManager.sendSwipeActionTo(user, action: .chatRequest)
        swipeManager.sendSwipeActionTo(user, action: .like)
        checkMatchAvailable(user)
    }
    
    func onTapFilters() {
        analyticsService.logEvent("Swipes_Tap_Filters")
        moduleOutput?.swipeModuleDidSelectFilters(self)
    }
    
    func onBecomePremium() {
        analyticsService.logEvent("Swipes_Tap_Premium")
        moduleOutput?.swipeModuleDidSelectPaywall(self)
    }
    
    private func checkMatchAvailable(_ profile: UserProfile) {
        guard let myUid = accountManager.uid else { return }
        #if DEBUG
        moduleOutput?.swipeModuleDidShowMatch(self, profile: profile)
        #else
        if profile.swipeInteractedWithProfiles.contains(myUid) {
            moduleOutput?.swipeModuleDidShowMatch(self, profile: profile)
        }
        #endif
    }
}

// MARK: - SwipeModuleInput

extension SwipePresenter: SwipeModuleInput {
    func reload() {
        updateData()
    }
    
    func dismiss() {
        view?.dismiss()
    }
}
