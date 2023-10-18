//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 17/09/2023.
//

import Foundation

final class ProfileImageService {
    
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    struct UserResult: Codable {
        let profile_image: ProfileImage
    }
    
    struct ProfileImage: Codable {
        let small: String
    }
    
    static let shared = ProfileImageService()
    
    private (set) var avatarURL: String?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        let username = "mrVol1"
        let apiUrl = URL(string: "https://api.unsplash.com/users/\(username)")!
        
        let tokenStorage = OAuth2TokenStorage()
        guard let token = tokenStorage.token else {
            completion(.failure(NSError(domain: "Token failed", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let dataTask = session.objectTask(for: request) { (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                let profileImageURL = userResult.profile_image.small
                self.avatarURL = profileImageURL
                completion(.success(profileImageURL))
                NotificationCenter.default.post(
                    name: ProfileImageService.DidChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL])
            case .failure(let error):
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }
}
