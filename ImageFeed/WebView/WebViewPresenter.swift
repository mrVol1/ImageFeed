//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 08/10/2023.
//

import Foundation

public protocol WebViewPresenterProtocol {
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
    var view: WebViewViewControllerProtocol? { get set }
}

final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol? //выполняется геттер переменной из экземпляра класса WebViewViewControllerProtocol
    var authHelper: AuthHelperProtocol //свойство класса без значения, поэтому ниже выполняется инциализация этого значения

    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }

    func viewDidLoad() {

        view?.load()
        didUpdateProgressValue(0)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        print("Presenter: didUpdateProgressValue(\(newValue))")
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)

        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
        print("Presenter: shouldHideProgress(\(newProgressValue)): \(shouldHideProgress)")
    }

    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }

    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
