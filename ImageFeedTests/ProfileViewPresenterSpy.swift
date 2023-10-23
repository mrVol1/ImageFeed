//
//  ProfileViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Eduard Karimov on 18/10/2023.
//

@testable import ImageFeed
import Foundation

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: ProfileViewControllerProtocol?
    var updateAvatarCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func updateAvatar() {
        updateAvatarCalled = true
    }
    
    
    func logOutInProduct(setAsRoot: Bool) {
        
    }
    
    
    func showLogoutAlert() {
        
    }
    
    func clearCookiesAndWebsiteData() {
        
    }
}
