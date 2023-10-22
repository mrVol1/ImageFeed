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
    func logoutButtonTapped()
    func logOutInProduct()
    func clearCookiesAndWebsiteData()
    var view: ProfileViewControllerProtocol? { get set }
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private var imageView = UIImageView()
    
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
        print("ViewDidLoad in presenter called")
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                print("ProfileImageService.DidChangeNotification received")
                self.updateAvatar()
            }
        updateAvatar()
        
    }
    
    func updateAvatar() {
        print("Update avatar in presenter called")
        guard let profileImageURL = ProfileImageService.shared.avatarURL, let url = URL(string: profileImageURL) else { return }
        print("Profile image URL: \(profileImageURL)")
        imageView.kf.setImage(with: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success(_):
                print("Image loaded successfully") // Отладочный принт в случае успешной загрузки изображения
                break
            case .failure(let error):
                print("Image loading failed: \(error)") // Отладочный принт в случае ошибки загрузки изображения
                break
            }
        }
    }
    
    func logoutButtonTapped() {
        view?.showLogoutAlert()
    }
    
    func logOutInProduct() {
        let tokenStorage = OAuth2TokenStorage()
        tokenStorage.token = nil
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            if let splashViewController = sceneDelegate.splashViewController {
                sceneDelegate.window?.rootViewController = splashViewController
            } else {
                let newSplashViewController = SplashViewController()
                sceneDelegate.splashViewController = newSplashViewController
                sceneDelegate.window?.rootViewController = newSplashViewController
            }
        }
        
        clearCookiesAndWebsiteData()
    }
    
    func clearCookiesAndWebsiteData() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
