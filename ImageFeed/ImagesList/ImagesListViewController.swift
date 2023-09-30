//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 30.07.2023.
//

import UIKit

final class ImagesListViewController: UIViewController {
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListService: ImagesListService?
    
    @IBOutlet private var tableView: UITableView!
    
    var photos: [Photo] = []
    var activityIndicator: UIActivityIndicatorView!
    private var photoId = "id"
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        imagesListService = ImagesListService()
        imagesListService?.fetchPhotosNextPage()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePhotosDidChange(_:)), name: ImagesListService.DidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handlePhotosDidChange(_ notification: Notification) {
        if let updatedPhotos = imagesListService?.photos {
            photos = updatedPhotos
            
            if Thread.isMainThread {
                tableView.reloadData()
            } else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
            var updatedPhoto = self.photos[index]
            updatedPhoto.isLiked = !updatedPhoto.isLiked
            self.photos[index] = updatedPhoto
        }
    }
    
    func updateTableViewAnimated() {
        let oldCount = tableView.numberOfRows(inSection: 0)
        let newCount = photos.count
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as! SingleImageViewController
            let indexPath = sender as! IndexPath
            let photo = photos[indexPath.row]
            viewController.photo = photo
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as! ImagesListCell
        cell.delegate = self
        
        configCell(for: cell, with: indexPath)
        print("Cell for row at indexPath: \(indexPath)")
        return cell
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        if let imageURL = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            
            cell.cellImage.kf.setImage(with: imageURL, placeholder: UIImage(named: "placeholder_image"), completionHandler: { [weak self] (result) in
                guard let self = self else { return }
                
                switch result {
                case .success(_):
                    if let indexPaths = self.tableView?.indexPathsForVisibleRows, indexPaths.contains(indexPath) {
                        self.tableView?.reloadRows(at: [indexPath], with: .automatic)
                    }
                case .failure(let error):
                    print("Ошибка при загрузке изображения: \(error)")
                }
            })
        }
        
        cell.labelView.text = dateFormatter.string(from: photo.createdAt!)
        let isLiked = photo.isLiked
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.buttonClick.setImage(likeImage, for: .normal)
        cell.indexPath = indexPath
        
        DispatchQueue.main.async {
            cell.delegate = self
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService?.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(at indexPath: IndexPath) {
        print("Like button tapped for cell at indexPath: \(indexPath)")
        
        let photo = photos[indexPath.row]
        // Покажем лоадер
        UIBlockingProgressHUD.show()
        imagesListService!.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                // Синхронизируем массив картинок с сервисом
                self.photos = self.imagesListService!.photos
                // Уберём лоадер
                UIBlockingProgressHUD.dismiss()
            case .failure:
                // Уберём лоадер
                UIBlockingProgressHUD.dismiss()
                // Покажем, что что-то пошло не так
                // TODO: Показать ошибку с использованием UIAlertController
                print("Error while changing like status")
            }
        }
    }
}
