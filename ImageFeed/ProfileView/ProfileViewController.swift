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

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateNameLabel(_ text: String)
    func updateLoginNameLabel(_ text: String)
    func updateDescriptionLabel(_ text: String)
    func updateAvatar(_ image: UIImage)
    func showErrorAlert()
    func showLogoutAlert()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
        
    private let profileService = ProfileService.shared
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var imageViewProfile = UIImageView()    
    private var logOut = UIButton()
    var presenter: ProfileViewPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageViewProfile)
        
        let presenter = ProfileViewPresenter(view: self)
        self.presenter = presenter
        presenter.viewDidLoad()
        
        if let token = OAuth2TokenStorage().token {
            ProfileService.shared.fetchProfile(token) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let profile):
                    self.nameLabel.text = profile.name
                    self.loginNameLabel.text = profile.loginName
                    self.descriptionLabel.text = profile.bio
                case .failure(_):
                    let alertController = UIAlertController(title: "Ошибка", message: "Произошла ошибка в приложении.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    present(alertController, animated: true, completion: nil)
                }
            }
        }

        if let profileImageURL = ProfileImageService.shared.avatarURL, let url = URL(string: profileImageURL) {
            print("Profile image URL: \(profileImageURL)")
            imageViewProfile.kf.setImage(with: url) { result in
                switch result {
                case .success(_):
                    print("Image loaded successfully")
                case .failure(let error):
                    print("Image loading failed: \(error)")
                }
            }
        }

        
        view.addSubview(imageViewProfile)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logOut)
        
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)

        imageViewProfile.translatesAutoresizingMaskIntoConstraints = false
        imageViewProfile.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageViewProfile.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageViewProfile.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageViewProfile.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageViewProfile.clipsToBounds = true
        imageViewProfile.layer.cornerRadius = 35
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.leadingAnchor.constraint(equalTo: imageViewProfile.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageViewProfile.bottomAnchor, constant: 8).isActive = true
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: UIFont.Weight.bold)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textColor = UIColor(hue: 230, saturation: 0.03, brightness: 0.7, alpha: 1)
        loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        loginNameLabel.textColor = UIColor(hue: 230, saturation: 0.03, brightness: 0.7, alpha: 1)
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = .white
        descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        descriptionLabel.textColor = .white
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        logOut.translatesAutoresizingMaskIntoConstraints = false
        logOut.setImage(UIImage(named: "Exit"), for: .normal)
        logOut.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logOut.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 65).isActive = true
        logOut.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logOut.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logOut.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        logOut.accessibilityIdentifier = "logOut"
    }
    
    @objc private func logoutButtonTapped() {
        presenter?.logoutButtonTapped()
    }
    
    func updateNameLabel(_ text: String) {
        nameLabel.text = text
    }
    
    func updateLoginNameLabel(_ text: String) {
        loginNameLabel.text = text
    }
    
    func updateDescriptionLabel(_ text: String) {
        descriptionLabel.text = text
    }
    
    func updateAvatar(_ image: UIImage) {
        print("Update avatar called")
        imageViewProfile.image = image
    }
    
    func showErrorAlert() {
        let alertController = UIAlertController(title: "Ошибка", message: "Произошла ошибка в приложении.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showLogoutAlert() {
        let alertController = UIAlertController(
            title: "Вы точно хотите выйти?",
            message: "Возвращайтесь еще",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "Да",
            style: .default,
            handler: { (_) in
                self.presenter?.logOutInProduct()
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
}
