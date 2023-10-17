//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 26/08/2023.
//

import Foundation
import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {//AnyObject - это значит что только классы могут подписываться на это протокол, а структуры и перечисления не могут
    var presenter: WebViewPresenterProtocol? { get set } //определяется переменную презентер вебвьюпрезентпротокола с геттером - получение данных переменной и сеттером - возможность переопределения данных в переменной
    var authRequest: URLRequest? { get set } // Добавьте это свойство
    func load(request: URLRequest) //функция загрузки с параметром запроса на получение урла
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
} //протокол включает в себя обязательные параметры и методы, которые должны быть выполненны внутри класса, который использует протокол

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) //метод который принимает значение вебвьюконтроллера и кода аутетификации
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    
    var presenter: WebViewPresenterProtocol? //используется геттер для переменной презенетер
    var authHelper: AuthHelperProtocol
    var authRequest: URLRequest?
    
    init(authHelper: AuthHelperProtocol) { //инициализация ауфхелпера, так как этот метод из другого класса и контроллеру нужно иметь к нему доступ
        self.authHelper = authHelper
        super.init(nibName: nil, bundle: nil)
        self.authRequest = authHelper.authRequest() // Инициализируем authRequest здесь
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    private let webView: WKWebView = { //создание константы webView
        let webView = WKWebView() //присваивание экземпляру класса WKWebView константу webView
        return webView //возвращение константы webView
    }()
    
    //Создание кнопки "Назад"
    private let backButton: UIButton = { //создание константы кнопки с типом UIButton
        let button = UIButton()
        let backImage = UIImage(systemName: "chevron.left")
        button.tintColor = .black
        button.setImage(backImage, for: .normal)
        button.addTarget(WebViewViewController.self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    //создание лоудера
    private let progressView: UIProgressView = { //создание константы лоудера с типом UIProgressView
        let indicator = UIProgressView()
        indicator.backgroundColor = .black
        return indicator
    }()
    
    weak var delegate: WebViewViewControllerDelegate?//вызов WebViewViewControllerDelegate, когда это надо и выполнение кода внутри WebViewViewControllerDelegate. Веб-вью контроллер подписывается на WebViewViewControllerDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //добавление вебвью и установка его делегата
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        //установка цвета бэкграунда
        self.view.backgroundColor = UIColor.white
        
        //добалвение кнопки "Назад"
        view.addSubview(backButton)
        
        //добавление лоудера
        view.addSubview(progressView)
        
        //настройка констрейтов для кнопки назад
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 21),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18)
        ])
        
        // настройка констрейтов для веб-вью
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        //настройка констрейтов для лоудера
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func load(request: URLRequest) {
        if let authRequest = authRequest {
            webView.load(authRequest)
        } else {
            // Обработка случая, когда authRequest равно nil
            // Вы можете выкинуть ошибку, вывести предупреждение и т. д., в зависимости от ваших потребностей.
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear called")

            if webView.isLoading {
                print("WebView is currently loading a page.")
            } else {
                print("WebView is not loading a page.")
            }
            
            if webView.url != nil {
                print("WebView has a URL: \(webView.url!)")
            } else {
                print("WebView does not have a URL.")
            }

            webView.addObserver(
                self,
                forKeyPath: #keyPath(WKWebView.estimatedProgress),
                options: .new,
                context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        print("observeValue called")
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    @objc private func didTapBackButton(_ sender: Any?) {
        print("WebViewViewController: didTapBackButton() called")
        delegate?.webViewViewControllerDidCancel(self)
    }
}

// MARK: - WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
    
    // Вызывается при начале загрузки
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("WebView didStartProvisionalNavigation")
    }

    // Вызывается при завершении загрузки
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WebView didFinish")
    }

    // Вызывается при возникновении ошибки
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("WebView didFailProvisionalNavigation with error: \(error)")
    }
}
