//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 31/08/2023.
//

import Foundation
import UIKit
import ProgressHUD

final class SplashViewController: UIViewController { //final означает, что класс нельзя наследовать
    private var authHelper = AuthHelper() //private, значит что переменную можно юзать только внутри класса
    private let profileService = ProfileService.shared //.shared позволяет дать доступ к единственному экземпляру класса ProfileService
    private let oauth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    override func viewDidLoad() { // функция, в которой начинается создаваться приложение, определяя его начальный вид и поведение, но не отображается для пользователя
        super.viewDidLoad()//вызов функции viewDidLoad, чтобы настроить первый экран прилы
        
        // Установка цвета фона экрана
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        let imageView = UIImageView(image: UIImage(named: "Vector"))
        imageView.translatesAutoresizingMaskIntoConstraints = false //позаоляет настроить картинку в приложении, как тебе хочется
        view.addSubview(imageView)//добавление в view картинки imageView
        
        //настройка констрейтов
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Размеры лого
        imageView.widthAnchor.constraint(equalToConstant: 74).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 76).isActive = true
    }
    
    override func viewDidAppear(_ animated: Bool) { //видимая часть экрана для пользователя, внутри можно настроить логику работы, как пользователь с ним взаимодействует
        super.viewDidAppear(animated)
        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
        } else {
            let authViewController = AuthViewController(authHelper: authHelper)
            authViewController.delegate = self //SplashViewController управляет контроллером ауф с помощью делегата
            authViewController.modalPresentationStyle = .fullScreen //ауф контроллер занимает весь экран
            present(authViewController, animated: true, completion: nil) //отображает ауф контроллер поверх сплешэкрана (потому что делегат юзал)
        }
    }
    
    private func switchToTabBarController() {
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true, completion: nil)
    }
}
// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate { //реализует расширение SplashViewController, чтобы реализовать протокол AuthViewControllerDelegate. После того как AuthViewController выполнил аутентификацию (получил токен авторизации), тогда SplashViewController выполняется поверх AuthViewController
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) { //реализация метода в протоколе AuthViewControllerDelegate, принимает токен авторизации и экземпляр класса ауфа. Экземпляр класса нужен для того, чтобы закрыть контроллер AuthViewController и отобразить только сплешконтроллер (код с этим ниже)
        UIBlockingProgressHUD.show() //показываем лоудер
        dismiss(animated: true) { [weak self] in // выполняется закрытие контроллера ауфа, и полностью вся логика на сплешконтроллере
            guard let self = self else { return } //выполняется замыкание, если сплешконтроллер сдох, тогда код ниже не выполняется
            self.fetchOAuthToken(code) //если сплешконтроллер существует, тогда выполняется метод fetchOAuthToken с токеном авторизации
        }
    }
    
    func fetchOAuthToken(_ code: String) { //выполнение функции с получение токена от OAuth2
        oauth2Service.fetchOAuthToken(code) { [weak self] result in //вызывается метод fetchOAuthToken из класса oauth2Service и в fetchOAuthToken передается code. { [weak self] result in - выполняется после выполнения запроса fetchOAuthToken(code), токен доступа записывается в result т.е выполняется ассинхронный код
            guard let self = self else { return } //проверка существует ли класс сплешконтроллера(self), Если сплешконтроллер есть, тогда выполняется код ниже, если нет, тогда выполняется ретурн
            switch result { // выполняется обработка результатов от переменной result
            case .success: //если кейс успех, тогда выполняется метод switchToTabBarController() в классе сплешконтроллера(поэтому селф)
                self.switchToTabBarController()
                UIBlockingProgressHUD.dismiss() //закрывается лоудер
            case .failure(_): // если кейс не успешный, тогда выходит ошибка
                UIBlockingProgressHUD.dismiss()
                break
            }
        }
    }
    private func fetchProfile(token: String) { //Получение данных о профиле, принимает значение токена аутентификации из условия if oauth2TokenStorage.token != nil
        ProfileService.shared.fetchProfile(token) { [weak self] result in //отправка запроса в контроллер профиля с токеном доступа и получение результата
            guard let self = self else { return } //проверка что резалт не нул. Если нул, тогда ретурн
            switch result { // выполнение проверки значения в резалт
            case .success: //успешная проверка и свитч в таббар контроллер
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case .failure: //неуспех в резалте
                UIBlockingProgressHUD.dismiss()
                self.showErrorAlert() //вывод алерта внутри класса сплешконтроллера
                break
            }
        }
    }
    
    func showErrorAlert() { //метод по отображению алерта
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
        
        alertController.addAction(okAction) //создание кнопки ок в алерте и при нажатии на кнопку алерт закроется
        
        present(alertController, animated: true, completion: nil) //вывод алерта на экран и completion нул, это значит что после закрытия алерта ничего не происходит
    }
}

