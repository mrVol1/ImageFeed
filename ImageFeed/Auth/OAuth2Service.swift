//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 28/08/2023.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue!
        }
    }
    
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) {
            assert(Thread.isMainThread)
            if lastCode == code { return }
            task?.cancel()
            lastCode = code
            let request = authTokenRequest(code: code)
            
            
            let fulfillCompletionOnMainThread: (Result<OAuthTokenResponseBody, Error>) -> Void = { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let tokenResponse):
                        let authToken = tokenResponse.accessToken
                        self.authToken = authToken
                        completion(.success(tokenResponse))
                        self.task = nil
                    case .failure(let error):
                        completion(.failure(error))
                        self.task = nil
                        self.lastCode = nil
                    }
                }
            }
            let task = urlSession.objectTask(for: request, completion: fulfillCompletionOnMainThread)
            self.task = task
            task.resume()
        }
    
    private func makeRequest(code: String) -> URLRequest {
        guard let url = URL(string: authURLUrlString) else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
// MARK: - OAuth2Service
extension OAuth2Service {
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(accessKeyKey)"
            + "&&client_secret=\(secretKeyKey)"
            + "&&redirect_uri=\(redirectURIUri)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: baseURLUrl
        )
    }
    struct OAuthTokenResponseBody: Decodable {
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case tokenType = "token_type"
            case scope
            case createdAt = "created_at"
        }
    }
}
// MARK: - HTTP Request
extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL = apiBaseURLUrl
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        return request
    }
}
// MARK: - Network Connection
enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let data = data, let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError))
                }
                return
            }
            if 200 ..< 300 ~= response.statusCode {
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(result))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
                }
            }
        }
        task.resume()
        return task
    }
}
