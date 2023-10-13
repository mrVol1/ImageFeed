//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 26/08/2023.
//

import Foundation
import UIKit
import WebKit

protocol AuthViewControllerDelegate: AnyObject { //может наследовать только классы
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    private var authHelper = AuthHelper()
//    var webViewViewController: WebViewViewController?
    weak var delegate: AuthViewControllerDelegate? //подписка на AuthViewControllerDelegate и выполнение метода authViewController
    
    init(authHelper: AuthHelper) { //инциализация экземпляра класса AuthViewController и передача туда параметра authHelper
        self.authHelper = authHelper //создается переменная authHelper, которая равна параметру authHelper класса AuthViewController
        super.init(nibName: nil, bundle: nil) //выполнение инциализации класса UIViewController
    }
    
    required init?(coder: NSCoder) { //загрузка архивированных данные, в приле не используется, но если удалить его тогда возникает ошибка
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() { //метод для определения свойств экрана. Пользователь этого не видит
        super.viewDidLoad() //выполнение метода
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
        logoImageView.translatesAutoresizingMaskIntoConstraints = false //можно в logoImageView задавать свои размеры и констрейты
        view.addSubview(logoImageView) //добавление во view объект logoImageView
        
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
        //loginButton.addTarget - это обработчик на нажатие кнопки
        //self - ауф контроллер будет отвечать за это событие (код этого ниже)
        //#selector(didTapLoginButton) - указывает какая функция должна быть выполнена при нажатии на кнопку
        //событие .touchUpInside - сообщает что должно выполнится после того, как пользователь убрал палец с кнопки
    }
    
    @objc private func didTapLoginButton() { //@objc - аннотация, которая может быть с обжект-си кодом
        let webViewViewController = WebViewViewController()//объект экземпляра класса вебвьювьюконтроллер
        let authHelper = AuthHelper() //объект класа ауфхелпера
        let webViewPresenter = WebViewPresenter(authHelper: authHelper) //создаем объект webViewPresenter экземпляра класса вебвьюпрезентер с параметром ауфхелпер
        webViewViewController.presenter = webViewPresenter //созданный объект webViewPresenter представляется как метод презентора из класса webViewViewController
        webViewPresenter.view = webViewViewController //вебвьюпрезентор работает с представлением на экране телефона
        webViewViewController.delegate = self //представление вебвью обрабатывается внутри ауфконтроллера
        present(webViewViewController, animated: true, completion: nil) //выполнение отображения webViewViewController на экране и после этого никакой код не выполняется так как completion = нул
    }
}
// MARK: - WebViewViewControllerDelegate
// это выполнение функций вебвьюконтроллера, внутри ауфконтроллера. Ауфконтроллер выполняет действия в зависимости от того какие события произошли в вебвьюконтроллере. Конкретно здесь - это вотправка этого кода в вебвьюконтроллер или отмена авторизации в webViewViewControllerDidCancel
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        //_ vc: WebViewViewController - параметр, который говорит методу что надо обращаться к экземпляру класса вебвьюконтроллера. (этот параметр нужен если в коде есть несколько контроллеров)
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    //метод отмены авторизации в вебвьюконтроллере
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
