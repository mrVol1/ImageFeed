//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 28/08/2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let keychain = KeychainWrapper.standard
    
    private let tokenKey = "jdsurUUes2!"
    
    var token: String? {
        get {
            return keychain.string(forKey: tokenKey)
        }
        
        set {
            if let newValue = newValue {
                keychain.set(newValue, forKey: tokenKey)
                print("Token saved in Keychain:", newValue)
            } else {
                keychain.removeObject(forKey: tokenKey)
                print("Token removed from Keychain")
            }
        }
    }
}
