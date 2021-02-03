//
//  SwipeAssembly.swift
//  LuvApp
//
//  Created by Vladislav Budruev on 25.11.2020.
//

import Foundation
import LuvAppCore

struct SwipeModuleAssembly {
    func makeModule(context: AppContext,
                    moduleOutput: SwipeModuleOutput? = nil) -> UIModule<SwipeModuleInput> {
        
        let presenter = SwipePresenter(moduleOutput: moduleOutput,
                                       analyticsService: context.eventsLogger,
                                       subscriptionManager: context.subscriptionManager,
                                       swipeManager: context.swipeManager,
                                       appStateManager: context.appStateManager,
                                       storageManager: context.storageService,
                                       accountManager: context.accountManager)
        
        let viewController = SwipeViewController(presenter: presenter)
        presenter.view = viewController
        return Module(view: viewController, moduleInput: presenter)
    }
}

protocol SwipeModuleInput: AnyObject {
    func dismiss()
    func reload()
}

protocol SwipeModuleOutput: AnyObject {
    func swipeModuleDidSelectGame(_ module: SwipeModuleInput, gameContent: GameContentType)
    func swipeModuleDidFinish(_ module: SwipeModuleInput)
    func swipeModuleDidShowMatch(_ module: SwipeModuleInput, profile: UserProfile)
    func swipeModuleDidSelectPaywall(_ module: SwipeModuleInput)
    func swipeModuleDidSelectFilters(_ module: SwipeModuleInput)
}
