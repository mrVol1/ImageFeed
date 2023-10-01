//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 25/09/2023.
//

import Foundation

final class ImagesListService {
    private (set) var photos: [Photo] = [] {
        didSet {
            NotificationCenter.default.post(name: ImagesListService.DidChangeNotification, object: self)
        }
    }
    
    static let DidChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private var lastLoadedPage: Int?
    private var isLoading = false
    private var currentPage = 1
    private var photoId = Photo.CodingKeys.id
    var isLike: Bool = false
    
    func fetchPhotosNextPage() {
        guard !isLoading else {
            return
        }
        
        isLoading = true
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let url = URL(string: "https://api.unsplash.com/photos?client_id=\(AccessKey)&page=\(self.currentPage)&per_page=10") else {
            isLoading = false
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if error != nil {
                print("Ошибка загрузки данных для URL: \(url)\nОшибка: \(error!.localizedDescription)")
                self.isLoading = false
                return
            }
            
            if let data = data {
                if String(data: data, encoding: .utf8) != nil {
                    //print("Полученные данные: \(String(data: data, encoding: .utf8) ?? "Невозможно прочитать данные")")
                } else {
                    print("Received data is not a valid UTF-8 string.")
                }
                
                DispatchQueue.main.async {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let photos = try decoder.decode([Photo].self, from: data)
                        
                        if photos.isEmpty {
                            print("Фотографий нет") // вывести алерт можно потом
                        } else {
                            if nextPage == 1 {
                                self.photos = photos
                            } else {
                                self.photos.append(contentsOf: photos)
                            }
                            self.lastLoadedPage = nextPage
                            self.currentPage += 1
                        }
                        
                        NotificationCenter.default.post(name: ImagesListService.DidChangeNotification, object: self)
                        
                    } catch {
                        print("Ошибка декодирования JSON: \(error.localizedDescription)")
                    }
                    
                    self.isLoading = false
                }
            }
        }
        
        task.resume()
    }
    
    //todo - функционал лайков
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = isLike ? "https://api.unsplash.com/photos/\(photoId)/like" : "https://api.unsplash.com/photos/\(photoId)/like"
        
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = isLike ? "POST" : "DELETE"
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.show()
            }
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                defer {
                    DispatchQueue.main.async {
                        UIBlockingProgressHUD.dismiss()
                    }
                }
                
                if let error = error {
                    completion(.failure(error))
                    print(error)
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    completion(.success(()))
                    print(response!)
                }
            }
            task.resume()
        } else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            completion(.failure(error))
        }
    }
}
