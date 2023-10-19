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

final class ImagesListViewController: UIViewController {
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListService: ImagesListService?
    var presenter: ImageListViewPresenterProtocol?
    var prepareResult: ImageListViewPresenterProtocol?
    
    @IBOutlet private var tableView: UITableView!
    
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
        presenter?.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

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
// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number of rows in table view: \(photos.count)")
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Configuring cell for row: \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as! ImagesListCell
        cell.delegate = self
        
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
                    if let indexPaths = self.tableView?.indexPathsForVisibleRows, indexPaths.contains(indexPath) {
                        self.tableView?.reloadRows(at: [indexPath], with: .automatic)
                    }
                case .failure(_):
                    break                }
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
        performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
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
