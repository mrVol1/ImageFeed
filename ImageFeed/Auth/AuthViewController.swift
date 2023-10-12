//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 26/08/2023.
//

import Foundation
import UIKit
import WebKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    private var authHelper = AuthHelper()
    var webViewViewController: WebViewViewController?
    weak var delegate: AuthViewControllerDelegate?
    
    init(authHelper: AuthHelper) {
        self.authHelper = authHelper
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Установка цвета фона экрана
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        // Создание кнопки "Войти"
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Войти", for: .normal)
        loginButton.setTitleColor(.black, for: .normal)
        loginButton.titleLabel?.font = UIFont(name: "SFPro-Bold", size: 17)
        loginButton.backgroundColor = .white
        loginButton.layer.cornerRadius = 16
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        
        // Создание UIImageView для логотипа
        let logoImageView = UIImageView(image: UIImage(named: "Logo_of_Unsplash"))
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        
        // Установка констрейтов для кнопки
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        // Размеры лого
        logoImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // установка констрейтов для логотипа
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Действие для кнопки "Войти"
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
    }
    
    @objc private func didTapLoginButton() {
        if let webViewVC = webViewViewController {
                let webViewPresenter = WebViewPresenter(authHelper: authHelper)
                webViewVC.presenter = webViewPresenter
                webViewPresenter.view = webViewVC
                webViewVC.delegate = self
                present(webViewVC, animated: true, completion: nil)
            }
    }
}
// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
