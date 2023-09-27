//
//  Constants.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 26/08/2023.
//

import Foundation

let AccessKey = "p0gNBIkL9LT9_tHKtNqnFCz-VVcNsIPhuyZuidLFRk8"
let SecretKey = "Us_MbHoDBlxc149nZIoMYFSaXEtNEHKG3QBH9UFVS_8"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"
let DefaultBaseURL = URL(string: "https://api.unsplash.com")!
let AuthURL = URL(string: "https://unsplash.com/oauth/authorize")
let BaseURL = URL(string: "https://unsplash.com")
let PhotoListURL = URL(string: "https://api.unsplash.com/photos?page=10&per_page=1")
