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
    func updateTableViewAnimated(withIndexPaths indexPaths: [IndexPath])
    func prepareResult(for segue: UIStoryboardSegue, sender: Any?)
    var view: ImageListViewControllerProtocol? { get set }
}

final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    var view: ImageListViewControllerProtocol?
    var presenter: ImageListViewPresenterProtocol?
    private var imagesListService: ImagesListService?
    var webViewViewController: WebViewViewControllerProtocol?
    var tableView: UITableView!
    
    var photos: [Photo] = []
    private var photoId = "id"
    
    func viewDidLoad() {
        
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        let presenter = ImageListViewPresenter()
        presenter.presenter = self
        
        imagesListService = ImagesListService()
        imagesListService?.fetchPhotosNextPage()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePhotosDidChange(_:)), name: ImagesListService.DidChangeNotification, object: nil)
    }
    
    @objc func handlePhotosDidChange(_ notification: Notification) {
        if let updatedPhotos = imagesListService?.photos {
            photos = updatedPhotos
            
            if Thread.isMainThread {
                view?.reloadTableView()
            } else {
                DispatchQueue.main.async {
                    self.view?.reloadTableView()
                }
            }
        }
        
        if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
            var updatedPhoto = self.photos[index]
            updatedPhoto.isLiked = !updatedPhoto.isLiked
            self.photos[index] = updatedPhoto
        }
    }
    
    func updateTableViewAnimated(withIndexPaths indexPaths: [IndexPath]) {
        let oldCount = tableView.numberOfRows(inSection: 0)
        let newCount = photos.count
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    func prepareResult(for segue: UIStoryboardSegue, sender: Any?) {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let photo = photos[indexPath.row]
            viewController.photo = photo
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController?.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
    }
}
