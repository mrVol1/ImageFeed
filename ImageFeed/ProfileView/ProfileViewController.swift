//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 14/08/2023.
//

import Foundation
import UIKit

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        
        let profileImage = UIImage(imageLiteralResourceName: "Photo.png")
        let imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        
        let labelName = UILabel()
        labelName.text = "Екатерина Новикова"
        labelName.font = UIFont.systemFont(ofSize: 23, weight: UIFont.Weight.bold)
        labelName.textColor = .white
        labelName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelName)
        labelName.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        labelName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        
        let labelTeg = UILabel()
        labelTeg.text = "@ekaterina_nov"
        labelTeg.textColor = UIColor(hue: 230, saturation: 0.03, brightness: 0.7, alpha: 1)
        //labelTeg.textColor = .gray
        labelTeg.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        labelTeg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelTeg)
        labelTeg.leadingAnchor.constraint(equalTo: labelName.leadingAnchor).isActive = true
        labelTeg.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 8).isActive = true
        
        let labelDiscription = UILabel()
        labelDiscription.text = "Hello, world!"
        labelDiscription.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        labelDiscription.textColor = .white
        labelDiscription.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(labelDiscription)
        labelDiscription.leadingAnchor.constraint(equalTo: labelTeg.leadingAnchor).isActive = true
        labelDiscription.topAnchor.constraint(equalTo: labelTeg.bottomAnchor, constant: 8).isActive = true
        
        let button = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: nil
        )
        button.tintColor = UIColor(hue: 360, saturation: 0.56, brightness: 0.96, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        
        // nameLabel
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        
        // loginNameLabel
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textColor = UIColor(hue: 230, saturation: 0.03, brightness: 0.7, alpha: 1)
        loginNameLabel.leadingAnchor.constraint(equalTo: labelName.leadingAnchor).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 8).isActive = true
        
        // descriptionLabel
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = .white
        descriptionLabel.leadingAnchor.constraint(equalTo: labelTeg.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: labelTeg.bottomAnchor, constant: 8).isActive = true
        
        profileService.fetchProfile(AccessKey) { result in
            switch result {
            case .success(let profile):
                self.nameLabel.text = profile.name
                self.loginNameLabel.text = profile.loginName
                self.descriptionLabel.text = profile.bio
            case .failure(let error):
                print("Ошибка при получении профиля: \(error)")
            }
        }
    }
}
