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
            return
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
                            print("Получен пустой массив фотографий.")
                        } else {
                            self.photos.append(contentsOf: photos)
                            print("Инициализированный Photo объект: \(photos)")
                            self.lastLoadedPage = nextPage
                        }
                        
                        NotificationCenter.default.post(name: ImagesListService.DidChangeNotification, object: self)
                        
                    } catch {
                        print("Ошибка декодирования JSON: \(error.localizedDescription)")
                        print("JSON data: \(String(data: data, encoding: .utf8) ?? "Невозможно прочитать данные")")
                    }
                    
                    self.isLoading = false
                }
            }
        }
        
        task.resume()
    }
}
