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
    var photos: [Photo] { get set }
    func updateTableViewAnimated(withIndexPaths indexPaths: [IndexPath])
}

final class ImagesListViewController: UIViewController, ImageListViewControllerProtocol {
    
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
        
        presenter?.view = self
        presenter?.viewDidLoad()
        
        imagesListService = ImagesListService()
        imagesListService?.fetchPhotosNextPage()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePhotosDidChange(_:)), name: ImagesListService.DidChangeNotification, object: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        navigationController?.navigationBar.barTintColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        
        // Создание констрейтов для размещения таблицы в представлении
        let leadingConstraint = tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingConstraint = tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let topConstraint = tableView.topAnchor.constraint(equalTo: view.topAnchor)
        let bottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        // Активация констрейтов
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let navController = navigationController {
            for _ in navController.viewControllers {
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Показываем навигационный бар
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        // Показываем таббар
        tabBarController?.tabBar.isHidden = false
    }
    
    @objc private func handlePhotosDidChange(_ notification: Notification) {
        if let updatedPhotos = imagesListService?.photos {
            photos = updatedPhotos
            reloadTableView()
        }
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
        return photos.count
    }
    
    func configureLikeButton(_ button: UIButton, isLiked: Bool, indexPath: IndexPath) {
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        button.accessibilityIdentifier = "likeButton"
        button.setImage(likeImage, for: .normal)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ImagesListCell()
        configCell(for: cell, with: indexPath)
        
        return cell
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        if let imageURL = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            
            cell.cellImage.kf.setImage(with: imageURL,
                                       placeholder: UIImage(named: "placeholder_image"),
                                       options: [.transition(.fade(0.2))],
                                       completionHandler: { [weak self] (result) in
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
        configureLikeButton(cell.buttonClick, isLiked: photo.isLiked, indexPath: indexPath)
        cell.indexPath = indexPath
        
        DispatchQueue.main.async {
            cell.delegate = self
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleImageViewController = SingleImageViewController()
        singleImageViewController.modalPresentationStyle = .fullScreen
        singleImageViewController.modalTransitionStyle = .coverVertical
        let photo = photos[indexPath.row]
        singleImageViewController.photo = photo
        if let navigationController = navigationController {
            navigationController.pushViewController(singleImageViewController, animated: true)
        } else {
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
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
            configureLikeButton(cell.buttonClick, isLiked: photo.isLiked, indexPath: indexPath)
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
