//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 14/08/2023.
//

import Foundation
import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var profileImageServiceObserver: NSObjectProtocol?
    private var imageView = UIImageView()
    private var logOut = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let token = OAuth2TokenStorage().token {
            ProfileService.shared.fetchProfile(token) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let profile):
                    self.nameLabel.text = profile.name
                    self.loginNameLabel.text = profile.loginName
                    self.descriptionLabel.text = profile.bio
                case .failure(let error):
                    let alertController = UIAlertController(title: "Ошибка", message: "Произошла ошибка в приложении.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    present(alertController, animated: true, completion: nil)
                    print("Error fetching profile: \(error)")
                }
            }
        }
        
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logOut)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.clipsToBounds = true 
        imageView.layer.cornerRadius = 35
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .white
        
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textColor = UIColor(hue: 230, saturation: 0.03, brightness: 0.7, alpha: 1)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = .white
        
        logOut.translatesAutoresizingMaskIntoConstraints = false
        logOut.setImage(UIImage(named: "Exit"), for: .normal)
        logOut.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logOut.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 65).isActive = true
        logOut.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logOut.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logOut.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        

        //Устанавливаем ограничения
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        logOut.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: UIFont.Weight.bold)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        loginNameLabel.textColor = UIColor(hue: 230, saturation: 0.03, brightness: 0.7, alpha: 1)
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        descriptionLabel.textColor = .white
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        imageView.kf.setImage(with: url)
    }
    
    @objc private func logoutButtonTapped() {
        let tokenStorage = OAuth2TokenStorage()
        tokenStorage.token = nil
        
        guard UIApplication.shared.delegate is AppDelegate else { return }
        let initialViewController = AuthViewController()
        
        UIApplication.shared.windows.first?.rootViewController = initialViewController
        
        clearCookiesAndWebsiteData()
    }
    
    private func clearCookiesAndWebsiteData() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
