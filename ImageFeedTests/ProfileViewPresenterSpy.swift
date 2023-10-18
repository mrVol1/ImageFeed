//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Eduard Karimov on 18/10/2023.
//

import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var viewDidLoadCalled: Bool = false
    var updateAvatarCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func updateAvatar() {
        updateAvatarCalled = true
    }
    
    func logoutButtonTapped() {
        
    }
    
    func logOutInProduct() {
        
    }
    
    func showLogoutAlert() {
        
    }
    
    func clearCookiesAndWebsiteData() {
        
    }
    
    
}
