//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 28/08/2023.
//

import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "BearerToken"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
