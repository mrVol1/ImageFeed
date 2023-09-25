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
        guard let url = PhotoListURL else {
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Ошибка загрузки данных: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let photos = try decoder.decode([PhotoData].self, from: data)
                    
                    self.photos.append(contentsOf: photos)
                    
                    self.lastLoadedPage = self.lastLoadedPage ?? 0 + 1
                    
                } catch {
                    print("Ошибка декодирования JSON: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
    }
}

