//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 17/09/2023.
//

import Foundation

final class ProfileImageService {
    
    struct UserResult: Codable {
        let profile_image: String
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        
    }
}
