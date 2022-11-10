//
//  ViewController.swift
//  VkNewsFeed
//
//  Created by Артём on 05.11.2022.
//

import UIKit
import VKSdkFramework

class AuthViewController: UIViewController {
    private var authService: AuthService!

    override func viewDidLoad() {
        super.viewDidLoad()
        authService = SceneDelegate.shared().authService
    }

    @IBAction func SignInTapped(_ sender: UIButton) {
        authService.wakeUpSession()
    }
    
}

