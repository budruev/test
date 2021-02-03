//
//  SwipeCoordinator.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 25.11.2020.
//

import Foundation
import UIKit
import LuvAppCore

final class SwipeCoordinator: BaseCoordinator {
    
    var didFinish: VoidCallback?
    
    private let appContext: AppContext
    private let navigationRouter: NavigationRouterProtocol
    
    private var swipeModuleInput: SwipeModuleInput?
    
    init(appContext: AppContext,
         navigationRouter: NavigationRouterProtocol) {
        self.appContext = appContext
        self.navigationRouter = navigationRouter
    }

    override func prepare() -> HasContainer {
        return navigationRouter
    }
    
    override func start() {
        showSwipeScreen()
    }
    
    private func showSwipeScreen() {
        let assembly = SwipeModuleAssembly()
        let module = assembly.makeModule(context: appContext, moduleOutput: self)
        
        navigationRouter.pushAndMakeFirst(module.view, animated: false)
    }
    
    private func openFilters() {
        let assembly = FiltersAssembly()
        let module = assembly.makeModule(context: appContext, moduleOutput: self)
        
        let navigationController = UINavigationController(rootViewController: module.view)
        navigationRouter.present(navigationController, animated: true, completion: nil)
    }
    
    private func showPaywall() {
        let assembly = MainPaywallModuleAssembly()
        let module = assembly.makeModule(context: appContext, paywallSource: .profile, moduleOutput: self)
        
        let navigationController = UINavigationController(rootViewController: module.view)
        navigationController.modalPresentationStyle = .overFullScreen
        
        navigationRouter.present(navigationController, animated: true, completion: nil)
    }
    
    private func showTrialPaywall() {
        let assembly = TrialPaywallModuleAssembly()
        let module = assembly.makeModule(context: appContext, paywallSource: .profile, moduleOutput: self)
        
        let navigationController = UINavigationController(rootViewController: module.view)
        navigationController.modalPresentationStyle = .overFullScreen
        
        navigationRouter.present(navigationController, animated: true, completion: nil)
    }
    
    private func showMatch(profile: UserProfile) {
        let assembly = MatchModuleAssembly()
        let module = assembly.makeModule(context: appContext, userProfile: profile, moduleOutput: self)
        
        let navigationController = UINavigationController(rootViewController: module.view)
        navigationRouter.present(navigationController, animated: true, completion: nil)
    }
    
    private func showLeaderboard() {
        let navigationController = UINavigationController()
        let navigationRouter = NavigationRouter(navigationController: navigationController)
        let coordinator = LeaderboardCoordinator(appContext: appContext,
                                                 navigationRouter: navigationRouter)
        
        addDependency(coordinator)
        coordinator.didFinish = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        
        let controller = coordinator.prepare().container
        controller.modalPresentationStyle = .overFullScreen
        
        self.navigationRouter.present(controller,
                                      animated: true,
                                      completion: nil)
        
        coordinator.start()
    }
    
    private func showGame(isMrMrsLuv: Bool) {
        guard appContext.storageService.todaySwipesCount < 10
                || appContext.subscriptionManager.isPremium else {
            showPaywall()
            return
        }
        let navigationController = UINavigationController()
        let navigationRouter = NavigationRouter(navigationController: navigationController)
        let coordinator = GameFlowCoordinator(appContext: appContext,
                                              isMrMrsLuv: isMrMrsLuv,
                                              navigationRouter: navigationRouter)
        
        addDependency(coordinator)
        coordinator.didFinish = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        
        let controller = coordinator.prepare().container
        controller.modalPresentationStyle = .overFullScreen
        
        self.navigationRouter.present(controller,
                                      animated: true,
                                      completion: nil)
        
        coordinator.start()
    }
    
    private func showAddQuestion() {
        let assembly = AddQuestionPopupModuleAssembly()
        let module = assembly.makeModule(context: appContext, moduleOutput: self)
        
        navigationRouter.presentPopup(with: module.view)
    }
}

// MARK: - SwipeModuleOutput

extension SwipeCoordinator: SwipeModuleOutput {
    func swipeModuleDidFinish(_ module: SwipeModuleInput) {
        module.dismiss()
    }
    
    func swipeModuleDidSelectFilters(_ module: SwipeModuleInput) {
        openFilters()
    }
    
    func swipeModuleDidSelectPaywall(_ module: SwipeModuleInput) {
        showPaywall()
    }
    
    func swipeModuleDidShowMatch(_ module: SwipeModuleInput, profile: UserProfile) {
        showMatch(profile: profile)
    }
    
    func swipeModuleDidSelectGame(_ module: SwipeModuleInput, gameContent: GameContentType) {
        switch gameContent {
        case .mrMrsLuvPlay:
            showGame(isMrMrsLuv: true)
        case .mrMrsLuvLeaderboard:
            showLeaderboard()
        case .mrMrsLuvGetMoreChances:
            showPaywall()
        case .popularityAnswer:
            showGame(isMrMrsLuv: false)
        case .popularityNewQuestion:
            showAddQuestion()
        case .popularityRating:
            showLeaderboard()
        }
    }
}

// MARK: - AddQuestionPopupModuleOutput

extension SwipeCoordinator: AddQuestionPopupModuleOutput {
    func addQuestionModuleDidFinish(_ module: AddQuestionPopupModuleInput) {
        module.dismiss {
            SnackBar(text: R.string.localizable.new_question_successfully_added(), style: .success).show()
        }
    }
}

// MARK: - FiltersModuleOutput

extension SwipeCoordinator: FiltersModuleOutput {
    func filtersModuleDidTapClose(_ moduleInput: FiltersModuleInput) {
        moduleInput.dismiss()
    }
}

// MARK: - MainPaywallModuleOutput

extension SwipeCoordinator: MainPaywallModuleOutput {
    func mainPaywallModuleDidPurchased(_ module: MainPaywallModuleInput) {
        module.dismiss()
        swipeModuleInput?.reload()
    }
    
    func mainPaywallModuleDidFinish(_ module: MainPaywallModuleInput) {
        module.dismiss()
    }
}

// MARK: - TrialPaywallModuleOutput

extension SwipeCoordinator: TrialPaywallModuleOutput {
    func trialPaywallModuleDidPurchased(_ module: TrialPaywallModuleInput) {
        module.dismiss()
        swipeModuleInput?.reload()
    }
    
    func trialPaywallModuleDidFinish(_ module: TrialPaywallModuleInput) {
        module.dismiss()
    }
}

extension SwipeCoordinator: MatchModuleOutput {
    func matchModuleDidFinish(_ moduleInput: MatchModuleInput) {
        moduleInput.dismiss()
    }
}
