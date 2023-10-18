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
    func setRequest(_ request: URLRequest)
    func load() //функция загрузки с параметром запроса на получение урла
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
    private var currentRequest: URLRequest?
    
    init(authHelper: AuthHelperProtocol) { //инициализация ауфхелпера, так как этот метод из другого класса и контроллеру нужно иметь к нему доступ
        self.authHelper = authHelper
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    private let webView: WKWebView = { //создание константы webView
        let webView = WKWebView() //присваивание экземпляру класса WKWebView константу webView
        webView.accessibilityIdentifier = "UnsplashWebView"
        return webView //возвращение константы webView
    }()
    
    //Создание кнопки "Назад"
    private let backButton: UIButton = { //создание константы кнопки с типом UIButton
        let button = UIButton()
        let backImage = UIImage(systemName: "chevron.left")
        button.tintColor = .black
        button.setImage(backImage, for: .normal)
        button.addTarget(target, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    //создание лоудера
    private let progressView: UIProgressView = { //создание константы лоудера с типом UIProgressView
        let indicator = UIProgressView()
        indicator.progressViewStyle = .default
        indicator.progressTintColor = UIColor.black
        return indicator
    }()
    
    weak var delegate: WebViewViewControllerDelegate?//вызов WebViewViewControllerDelegate, когда это надо и выполнение кода внутри WebViewViewControllerDelegate. Веб-вью контроллер подписывается на WebViewViewControllerDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WebViewViewController: viewDidLoad called")
        
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
        let constraints = [
            progressView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: webView.trailingAnchor)
        ]
        
        for constraint in constraints {
            constraint.isActive = true
        }
    }
    
    func setRequest(_ request: URLRequest) {
        currentRequest = request
    }
    
    func load() {
        if let request = currentRequest {
            webView.load(request)
        } else {
            print("error")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        
        setProgressValue(Float(webView.estimatedProgress))
        setProgressHidden(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
            setProgressValue(Float(webView.estimatedProgress))

            // Вызываем функцию shouldHideProgress на вашем презентере для определения видимости лоудера
            if let presenter = presenter {
                let shouldHide = presenter.shouldHideProgress(for: Float(webView.estimatedProgress))
                setProgressHidden(shouldHide)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func setProgressValue(_ newValue: Float) {
        print("ViewController: setProgressValue(\(newValue))")
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        print("ViewController: setProgressHidden(\(isHidden))")
        progressView.isHidden = isHidden
    }
    
    @objc private func didTapBackButton(_ sender: Any?) {
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
}
