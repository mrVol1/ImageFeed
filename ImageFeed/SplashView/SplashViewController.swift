//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 31/08/2023.
//

import Foundation
import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private var authHelper = AuthHelper()
    private let profileService = ProfileService.shared
    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Установка цвета фона экрана
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        let imageView = UIImageView(image: UIImage(named: "Vector"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Размеры лого
        imageView.widthAnchor.constraint(equalToConstant: 74).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 76).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear is called")
        
        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
        } else {
            let authViewController = AuthViewController(authHelper: authHelper)
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true, completion: nil)
            print("AuthViewController presented")
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
        
        print("Switched to TabBarController")
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
                UIBlockingProgressHUD.dismiss()
                print("OAuth token fetched successfully")
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("OAuth token fetching failed with error: \(error)")
                break
            }
        }
    }
    private func fetchProfile(token: String) {
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.showErrorAlert()
                break
            }
        }
    }
    
    func showErrorAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "Ок",
            style: .default,
            handler: nil
        )
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

