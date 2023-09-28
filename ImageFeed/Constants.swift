//
//  Constants.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 26/08/2023.
//

import Foundation

let AccessKey = "a6a-B5zaXFVzNmKbon3HTzgQ-o4g2mjfXdfITxLFA3w"
let SecretKey = "AQ6DxGalQGpMXzQVWYOI0aOQA6DKwU6KY8ARaBwQn14"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"
let DefaultBaseURL = URL(string: "https://api.unsplash.com")!
let AuthURL = URL(string: "https://unsplash.com/oauth/authorize")
let BaseURL = URL(string: "https://unsplash.com")
let PhotoListURL = URL(string: "https://api.unsplash.com/photos?client_id=\(AccessKey)&page=10000&per_page=10")
