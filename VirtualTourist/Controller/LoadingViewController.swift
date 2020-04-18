//
//  LoadingViewController.swift
//  VirtualTourist
//
//  Created by Kittikawin Sontinarakul on 18/4/2563 BE.
//  Copyright © 2563 Kittikawin Sontinarakul. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet weak var activityIndecator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndecator.startAnimating()
        checkFirstRunningApp(interval: 1)
        
    }
    
    func checkFirstRunningApp(interval: TimeInterval) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            if !UserDefaults.standard.bool(forKey: "isFirstLaunch") {
                self.performSegue(withIdentifier: K.Segue.onboardingPage, sender: nil)
            } else {
                let viewController = UIStoryboard(name: K.StoryboardID.main, bundle: nil).instantiateViewController(identifier: K.StoryboardID.mapMain)
                let sceneDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
                let window = sceneDelegate.window
                window?.rootViewController = viewController
                self.activityIndecator.stopAnimating()
            }
        }
    }
}
