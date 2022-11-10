//
//  AuthService.swift
//  VkNewsFeed
//
//  Created by Артём on 06.11.2022.
//

import Foundation
import VKSdkFramework
import UIKit

protocol AuthServiceDelegate: AnyObject {
    func authServiceShouldShow(viewController: UIViewController)
    func authServiceSignInSuccess()
    func authServiceSignInFailure()
    
}

class AuthService: NSObject, VKSdkDelegate, VKSdkUIDelegate {
   
    private let appId = "51469119"
    private let vkSdk: VKSdk
    
    weak var delegate: AuthServiceDelegate?
    
    var token: String? {
        VKSdk.accessToken().accessToken
    }
    
    var userId: String? {
        return VKSdk.accessToken().userId
    }
    
    override init() {
        vkSdk = VKSdk.initialize(withAppId: appId)
        super.init()
        vkSdk.register(self)
        vkSdk.uiDelegate = self
    }
    
    func wakeUpSession() {
        let scope = ["wall", "friends"]
        VKSdk.wakeUpSession(scope) { state, error in
            switch state {
            case .initialized:
                VKSdk.authorize(scope)
            case .authorized:
                self.delegate?.authServiceSignInSuccess()
            default:
                self.delegate?.authServiceSignInFailure()
            }
        }
        
    }
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if result.token != nil {
            delegate?.authServiceSignInSuccess()
        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        delegate?.authServiceSignInFailure()
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        delegate?.authServiceShouldShow(viewController: controller)
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        
    }
}
