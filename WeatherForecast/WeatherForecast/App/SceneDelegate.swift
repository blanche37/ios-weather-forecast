//
//  WeatherForecast - SceneDelegate.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let repository: Repository = NetworkRepository()
        let useCase: UseCase = WeatherUseCase(repository: repository)
        let viewModel: ViewModel = WeatherViewModel(useCase: useCase)
        let rootViewController = WeatherInfoViewController()
        rootViewController.viewModel = viewModel
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    
    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        guard let rootViewController = window?.rootViewController as? WeatherInfoViewController else {
            return
        }
        
        rootViewController.animationView.play()
    }
}
