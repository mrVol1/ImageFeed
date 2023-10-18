//
//  ProfileViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Eduard Karimov on 18/10/2023.
//

import ImageFeed
import Foundation

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func updateAvatar() {

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
