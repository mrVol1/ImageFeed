//
//  ImageListViewPresenter.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 19/10/2023.
//

import Foundation
import UIKit

public protocol ImageListViewPresenterProtocol {
    func viewDidLoad()
    func handlePhotosDidChange(_ notification: Notification)
    func setView(_ view: ImageListViewControllerProtocol)
    var view: ImageListViewControllerProtocol? { get set }
}

final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    private var imagesListService: ImagesListService
    private var photoId = "id"
    
    init(imagesListService: ImagesListService) {
        self.imagesListService = imagesListService
    }
    
    public weak var view: ImageListViewControllerProtocol?
    
    func setView(_ view: ImageListViewControllerProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        // Настройка начальных условий и запрос данных
        imagesListService.fetchPhotosNextPage()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePhotosDidChange(_:)), name: ImagesListService.DidChangeNotification, object: nil)
    }
    
    @objc func handlePhotosDidChange(_ notification: Notification) {
        let updatedPhotos = imagesListService.photos
        view?.photos = updatedPhotos // Обновить данные в контроллере
        view?.reloadTableView()
        
        if let index = view?.photos.firstIndex(where: { $0.id == photoId }) {
            if var updatedPhoto = view?.photos[index] {
                updatedPhoto.isLiked = !updatedPhoto.isLiked
                view?.photos[index] = updatedPhoto
            }
        }
    }

    func updateTableViewAnimated(withIndexPaths indexPaths: [IndexPath]) {
        view?.updateTableViewAnimated(withIndexPaths: indexPaths)
    }
}
