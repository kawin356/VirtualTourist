////
////  PresentationManager.swift
////  VirtualTourist
////
////  Created by Kittikawin Sontinarakul on 18/4/2563 BE.
////  Copyright © 2563 Kittikawin Sontinarakul. All rights reserved.
////
//
//import UIKit
//
//class PresentaionManager {
//    static let share = PresentaionManager()
//
//    private init() {}
//
//    enum VC {
//        case MainTabBarController
//        case OnboardingViewController
//    }
//
//    func show (vc: VC){
//        var viewContoller: UIViewController
//        
//        switch vc {
//        case .MainTabBarController:
//            viewContoller = UIStoryboard(name: K.StoryboardID.main, bundle: nil)
//                .instantiateViewController(identifier: K.StoryboardID.mainTabBarController)
//        case .OnboardingViewController:
//            viewContoller = UIStoryboard(name: K.StoryboardID.main, bundle: nil)
//                .instantiateViewController(identifier: K.StoryboardID.onboardingViewController)
//        }
//
//        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
//            let window = sceneDelegate.window {
//            window.rootViewController = viewContoller
//            UIView.transition(with: window, duration: 0.25,
//            options: .transitionCrossDissolve,
//            animations: nil, completion: nil)
//        }
//    }
//}
//
