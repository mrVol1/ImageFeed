//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Eduard Karimov on 19/10/2023.
//

import Foundation
@testable import ImageFeed
import UIKit
import WebKit

class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfileViewPresenterProtocol?
    var httpCookieStorage: HTTPCookieStorageProtocol?
    var wkWebsiteDataStore: WKWebsiteDataStoreProtocol?
    var avatarImage: UIImage?
    
    func updateNameLabel(_ text: String) {
        
    }
    
    func updateLoginNameLabel(_ text: String) {
        
    }
    
    func updateDescriptionLabel(_ text: String) {
        
    }
    
    func showErrorAlert() {
        
    }
    
    func showLogoutAlert() {
        
    }
    
    func clearCookiesAndWebsiteData() {
        httpCookieStorage?.removeCookies(since: Date())
        wkWebsiteDataStore?.fetchDataRecords(ofTypes: ["exampleType"]) { records in
        }
    }
    
    // Реализация метода updateAvatar
    func updateAvatar(_ image: UIImage) {
        avatarImage = image
    }
    
    // Реализация методов из HTTPCookieStorageProtocol
    func removeCookies(since date: Date) {
        // Ваша логика для удаления куков
    }
    
    // Реализация методов из WKWebsiteDataStoreProtocol
    func fetchDataRecords(ofTypes dataTypes: [String], completionHandler: @escaping ([WKWebsiteDataRecord]) -> Void) {
        // Ваша логика для получения данных
    }
    
    func removeData(ofTypes dataTypes: [String], for dataRecords: [WKWebsiteDataRecord], completionHandler: @escaping () -> Void) {
        // Ваша логика для удаления данных
    }
}

