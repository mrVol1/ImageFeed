//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 26/08/2023.
//

import Foundation

let accessKeyKey = "a6a-B5zaXFVzNmKbon3HTzgQ-o4g2mjfXdfITxLFA3w"
let secretKeyKey = "AQ6DxGalQGpMXzQVWYOI0aOQA6DKwU6KY8ARaBwQn14"
let redirectURIUri = "urn:ietf:wg:oauth:2.0:oob"
let accessScopeScope = "public+read_user+write_likes"
let apiBaseURLUrl = URL(string: "https://api.unsplash.com")!
let authURLUrlString = "https://unsplash.com/oauth/authorize"
let baseURLUrl = URL(string: "https://unsplash.com")!

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let apiBaseURL: URL
    let authURLString: String
    let baseURL: URL
    
    init(accessKey: String, 
         secretKey: String,
         redirectURI: String,
         accessScope: String,
         apiBaseURL: URL,
         authURLString: String,
         baseURL: URL
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.apiBaseURL = apiBaseURL
        self.authURLString = authURLString
        self.baseURL = baseURL
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: accessKeyKey,
                                 secretKey: secretKeyKey,
                                 redirectURI: redirectURIUri,
                                 accessScope: accessScopeScope,
                                 apiBaseURL: apiBaseURLUrl,
                                 authURLString: authURLUrlString,
                                 baseURL: baseURLUrl
        )
    }
}
