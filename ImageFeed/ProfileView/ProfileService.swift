//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 15/09/2023.
//

import Foundation

final class ProfileService {
    
    static let shared = ProfileService()
    private(set) var profile: Profile?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    
    struct ProfileResult: Codable {
        let username: String
        let first_name: String
        let last_name: String
        let bio: String
    }
    
    struct Profile: Codable {
        let username: String
        let name: String
        let loginName: String
        let bio: String
    }
    
    private func name(first_name: String, last_name: String) -> String {
        var user_name: String
        if first_name != "" && last_name != "" {
            user_name = first_name + last_name
        } else {
            user_name = first_name
        }
        return user_name
    }
    
    private func loginName (name: String) -> String {
        return "@" + name
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastToken == token { return }
        task?.cancel()
        lastToken = token
        let request = makeRequestToken(token: token)
        
        let task = urlSession.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let username = profileResult.username
                let name = self.name(first_name: profileResult.first_name, last_name: profileResult.last_name)
                let loginName = self.loginName(name: name)
                let bio = profileResult.bio
                ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in
                    let profile = Profile(username: username, name: name, loginName: loginName, bio: bio)
                    completion(.success(profile))
                }
            case .failure(let error):
                completion(.failure(error))
            }
            self.lastToken = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeRequestToken(token: String) -> URLRequest {
        guard let url = URL(string: "...\(token)") else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
