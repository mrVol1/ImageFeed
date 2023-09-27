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
    
    func fetchPhotosNextPage() {
        guard !isLoading else {
            return // Если загрузка уже выполняется, не выполняем новый запрос
        }
        
        isLoading = true
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let url = PhotoListURL else {
            isLoading = false
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Ошибка загрузки данных для URL: \(url)\nОшибка: \(error.localizedDescription)")
                self.isLoading = false
                return
            }
            
            if let data = data {
                DispatchQueue.main.async {
                    do {
                        let decoder = JSONDecoder()
                        let photos = try decoder.decode([Photo].self, from: data)
                        
                        if photos.isEmpty {
                            print("Получен пустой массив фотографий.")
                        } else {
                            self.photos.append(contentsOf: photos)
                            self.lastLoadedPage = nextPage
                        }
                        
                    } catch {
                        print("Ошибка декодирования JSON: \(error.localizedDescription)")
                    }
                    
                    self.isLoading = false
                }
            }
        }
        
        task.resume()
    }
}
