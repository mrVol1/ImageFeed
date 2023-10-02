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
    
    private let gradientForAvatar = CAGradientLayer()
    private let gradientForNameLabel = CAGradientLayer()
    private let gradientForLoginNameLabel = CAGradientLayer()
    private let gradientForDescriptionLabel = CAGradientLayer()
    var animationLayers = Set<CALayer>()
    
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
        
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 0.5).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 0.5).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 0.5).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 35
        gradient.masksToBounds = true
        animationLayers.insert(gradient)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        // Слой градиента и настройте его для nameLabel
        gradientForNameLabel.frame = nameLabel.bounds
        gradientForNameLabel.locations = [0, 0.1, 0.3]
        gradientForNameLabel.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 0.5).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 0.5).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 0.5).cgColor
        ]
        gradientForNameLabel.startPoint = CGPoint(x: 0, y: 0.5)
        gradientForNameLabel.endPoint = CGPoint(x: 1, y: 0.5)
        nameLabel.layer.addSublayer(gradientForNameLabel)
        
        // Анимация для слоя градиента nameLabel
        let gradientChangeAnimationForNameLabel = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimationForNameLabel.duration = 1.0
        gradientChangeAnimationForNameLabel.repeatCount = .infinity
        gradientChangeAnimationForNameLabel.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimationForNameLabel.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimationForNameLabel, forKey: "locationsChange")
        
        // Слой градиента для loginNameLabel
        gradientForLoginNameLabel.frame = loginNameLabel.bounds
        gradientForLoginNameLabel.locations = [0, 0.1, 0.3]
        gradientForLoginNameLabel.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 0.5).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 0.5).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 0.5).cgColor
        ]
        gradientForLoginNameLabel.startPoint = CGPoint(x: 0, y: 0.5)
        gradientForLoginNameLabel.endPoint = CGPoint(x: 1, y: 0.5)
        loginNameLabel.layer.addSublayer(gradientForLoginNameLabel)
        
        // Анимация для слоя градиента loginNameLabel
        let gradientChangeAnimationForLoginNameLabel = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimationForLoginNameLabel.duration = 1.0
        gradientChangeAnimationForLoginNameLabel.repeatCount = .infinity
        gradientChangeAnimationForLoginNameLabel.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimationForLoginNameLabel.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimationForLoginNameLabel, forKey: "locationsChange")
        
        // Слой градиента и анимации для descriptionLabel
        gradientForDescriptionLabel.frame = descriptionLabel.bounds
        gradientForDescriptionLabel.locations = [0, 0.1, 0.3]
        gradientForDescriptionLabel.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 0.5).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 0.5).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 0.5).cgColor
        ]
        gradientForDescriptionLabel.startPoint = CGPoint(x: 0, y: 0.5)
        gradientForDescriptionLabel.endPoint = CGPoint(x: 1, y: 0.5)
        descriptionLabel.layer.addSublayer(gradientForDescriptionLabel)
        
        // Анимация для descriptionLabel
        let gradientChangeAnimationForDescriptionLabel = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimationForDescriptionLabel.duration = 1.0
        gradientChangeAnimationForDescriptionLabel.repeatCount = .infinity
        gradientChangeAnimationForDescriptionLabel.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimationForDescriptionLabel.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimationForDescriptionLabel, forKey: "locationsChange")
        
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                if ProfileImageService.shared.avatarURL != nil {
                    self.imageView.layer.addSublayer(self.gradientForAvatar)
                    self.nameLabel.layer.addSublayer(self.gradientForNameLabel)
                    self.loginNameLabel.layer.addSublayer(self.gradientForLoginNameLabel)
                    self.descriptionLabel.layer.addSublayer(self.gradientForDescriptionLabel)
                } else {
                    self.gradientForAvatar.removeFromSuperlayer()
                    self.gradientForNameLabel.removeFromSuperlayer()
                    self.gradientForLoginNameLabel.removeFromSuperlayer()
                    self.gradientForDescriptionLabel.removeFromSuperlayer()
                }
            }
    }
    
    private func updateAvatar() {
        imageView.layer.addSublayer(gradientForAvatar)
        
        guard let profileImageURL = ProfileImageService.shared.avatarURL, let url = URL(string: profileImageURL) else { return }

        imageView.kf.setImage(with: url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                self.gradientForAvatar.removeFromSuperlayer()
                
            case .failure(let error):
                print("Error loading profile image: \(error)")
            }
        }
    }

    
    @objc private func logoutButtonTapped() {
        self.showLogoutAlert()
    }
    
    private func logOutInProduct() {
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
    
    
    
    private func showLogoutAlert() {
        let alertController = UIAlertController(
            title: "Вы точно хотите выйти?",
            message: "Возвращайтесь еще",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "Да",
            style: .default,
            handler: { (_) in
                self.logOutInProduct()
            }
        )
        
        let noAction = UIAlertAction(
            title: "Нет",
            style: .default,
            handler: nil
        )
        
        alertController.addAction(okAction)
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
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
