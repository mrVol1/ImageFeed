//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 25/09/2023.
//

import Foundation

final class ImagesListService {
    private (set) var photos: [PhotoData] = []
    
    private var lastLoadedPage: Int?
    
    func fetchPhotosNextPage() {
        // Создаем URL для вашего API
        guard let url = URL(string: "https://api.example.com/photos?page=\(lastLoadedPage ?? 1)") else {
            return
        }
        
        // Создаем сессию URLSession
        let session = URLSession.shared
        
        // Создаем задачу для получения данных
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Ошибка загрузки данных: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                do {
                    // Декодируем JSON-данные в массив фотографий
                    let decoder = JSONDecoder()
                    let photos = try decoder.decode([PhotoData].self, from: data)
                    
                    // Добавляем загруженные фотографии к существующему массиву
                    self.photos.append(contentsOf: photos)
                    
                    // Увеличиваем номер последней загруженной страницы
                    self.lastLoadedPage = self.lastLoadedPage ?? 0 + 1
                    
                    // Здесь вы можете обновить пользовательский интерфейс
                } catch {
                    print("Ошибка декодирования JSON: \(error.localizedDescription)")
                }
            }
        }
        
        // Запускаем задачу для получения данных
        task.resume()
    }
}

