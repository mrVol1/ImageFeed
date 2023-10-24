//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 18/10/2023.
//

// ProfileViewPresenter.swift

import Foundation
import UIKit
import WebKit

public protocol ProfileViewPresenterProtocol {
    func viewDidLoad()
    func updateAvatar()
    func logOutInProduct(setAsRoot: Bool)
    func clearCookiesAndWebsiteData()
    var view: ProfileViewControllerProtocol? { get set }
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private var imageViewProfilePresenter = UIImageView()
    
    init(view: ProfileViewControllerProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        if let token = OAuth2TokenStorage().token {
            ProfileService.shared.fetchProfile(token) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let profile):
                    self.view?.updateNameLabel(profile.name)
                    self.view?.updateLoginNameLabel(profile.loginName)
                    self.view?.updateDescriptionLabel(profile.bio)
                case .failure(_):
                    self.view?.showErrorAlert()
                }
            }
        }
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
        
    }
    
    func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL, let url = URL(string: profileImageURL) else { return }
        imageViewProfilePresenter.kf.setImage(with: url) { [weak self] result in
            guard self != nil else { return }
        }
    }

    
    func logOutInProduct(setAsRoot: Bool) {
        
        let tokenStorage = OAuth2TokenStorage()
        tokenStorage.token = nil
        
        if setAsRoot, let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = sceneDelegate.splashViewController
            }
            clearCookiesAndWebsiteData()
    }

    
    func clearCookiesAndWebsiteData() {
        
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) {
                }
            }
        }
    }
}
