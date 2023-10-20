//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 30.07.2023.
//

import UIKit

public protocol ImageListViewControllerProtocol: AnyObject {
    var presenter: ImageListViewPresenterProtocol? { get set }
    var prepareResult: ImageListViewPresenterProtocol? {get set}
    func reloadTableView()
}

class ImagesListViewController: UIViewController, ImageListViewControllerProtocol {
    
    private var imagesListService: ImagesListService?
    var presenter: ImageListViewPresenterProtocol?
    var prepareResult: ImageListViewPresenterProtocol?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    var photos: [Photo] = []
    private var photoId = "id"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ImagesListViewController: View did load")
        if let presenter = presenter {
            presenter.viewDidLoad()
        } else {
            print("Presenter is nil.")
        }

        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        // Создание констрейтов для размещения таблицы в представлении
        let leadingConstraint = tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingConstraint = tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let topConstraint = tableView.topAnchor.constraint(equalTo: view.topAnchor)
        let bottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        // Активация констрейтов
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        
        // Здесь вы можете добавить настройку интерфейса и других компонентов
        // Например, добавление таблицы и других элементов интерфейса.
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handlePhotosDidChange(_ notification: Notification) {
        presenter?.handlePhotosDidChange(notification)
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func performBatchUpdates(for indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func updateTableViewAnimated(withIndexPaths indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            self.performBatchUpdates(for: indexPaths)
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows in table view: \(photos.count)")
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Configuring cell for row: \(indexPath.row)")
        
        let cell = ImagesListCell()
        configCell(for: cell, with: indexPath)
                
        return cell
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        if let imageURL = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            
            cell.cellImage.kf.setImage(with: imageURL, placeholder: nil, completionHandler: { [weak self] (result) in
                guard let self = self else { return }
                
                switch result {
                case .success(_):
                    if let indexPaths = self.tableView.indexPathsForVisibleRows, indexPaths.contains(indexPath) {
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                case .failure(_):
                    break
                }
            })
        }
        
        if let createdAt = photo.createdAt {
            cell.labelView.text = dateFormatter.string(from: createdAt)
        } else {
            cell.labelView.text = ""
            cell.labelView.backgroundColor = UIColor(patternImage: UIImage(named: "placeholder_image")!)
        }
        let isLiked = photo.isLiked
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.buttonClick.setImage(likeImage, for: .normal)
        cell.indexPath = indexPath
        
        DispatchQueue.main.async {
            cell.delegate = self
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row: \(indexPath.row)")
            let singleImageViewController = SingleImageViewController()
            let photo = photos[indexPath.row]
            singleImageViewController.photo = photo
            navigationController?.pushViewController(singleImageViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Will display cell for row: \(indexPath.row)")
        if indexPath.row == photos.count - 1 {
            imagesListService?.fetchPhotosNextPage()
        }
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(at indexPath: IndexPath, isLike: Bool) {
        
        var photo = photos[indexPath.row]
        
        if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
            let likeImage = isLike ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
            cell.buttonClick.setImage(likeImage, for: .normal)
        }
        
        photo.isLiked = isLike
        photos[indexPath.row] = photo
        
        imagesListService!.changeLike(photoId: photo.id, isLike: isLike) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
                
            case .failure:
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Ошибка", message: "Что-то пошло не так", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    
                    photo.isLiked = !isLike
                    self.photos[indexPath.row] = photo
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
}
