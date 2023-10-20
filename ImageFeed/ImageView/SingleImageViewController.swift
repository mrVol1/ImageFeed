//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 14/08/2023.
//

import Foundation
import UIKit
import ProgressHUD
import Kingfisher

final class SingleImageViewController: UIViewController {
    var photo: Photo?
    let fullSingleImageViewController = FullSingleImageViewController()
    
    // Создаем интерфейсные элементы
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка экрана
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(didTapBackButton))
        
        loadAndDisplayImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    @objc private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    func didTapShareButton(_ sender: UIButton) {
        if let imageToShare = imageView.image {
            let sharingImage = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
            present(sharingImage, animated: true)
        } else {
            let alertController = UIAlertController(title: "Ошибка", message: "Произошла ошибка, повторите попозже", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    private func loadAndDisplayImage() {
        guard let imageURLString = photo?.largeImageURL, let imageURL = URL(string: imageURLString) else {
            return
        }
        
        UIBlockingProgressHUD.show()
        
        imageView.kf.indicatorType = .none
        imageView.kf.setImage(with: imageURL, placeholder: nil, completionHandler: { [weak self] (result: Result<RetrieveImageResult, KingfisherError>) in
            switch result {
            case .success(_):
                print("Image loaded successfully")
                UIBlockingProgressHUD.dismiss()
                print("Image size: \(self?.imageView.image?.size ?? .zero)")
                print("Before rescale and center")
                self?.fullSingleImageViewController.rescaleAndCenterImageInScrollView(image: self?.imageView.image ?? UIImage())
                print("After rescale and center")
                if let image = self?.imageView.image {
                    print("Setting the image in fullSingleImageViewController")
                    self?.fullSingleImageViewController.setImage(image)
                }
                if let navigationController = self?.navigationController, let fullSingleImageViewController = self?.fullSingleImageViewController {
                    navigationController.setViewControllers([fullSingleImageViewController], animated: true)
                }
            case .failure(let error):
                print("Image loading failed with error: \(error)")
                UIBlockingProgressHUD.dismiss()
                let alert = UIAlertController(title: "Ошибка", message: "Что-то пошло не так. Попробовать ещё раз?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Не надо", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] (_) in
                    self?.loadAndDisplayImage()
                })
                )
                self?.present(alert, animated: true, completion: nil)
            }
        })
        
    }
}
// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
