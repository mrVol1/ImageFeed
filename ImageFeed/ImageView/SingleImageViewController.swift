//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 14/08/2023.
//

import Foundation
import UIKit
import ProgressHUD

final class SingleImageViewController: UIViewController {
    var photo: Photo?

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
        view.backgroundColor = .white

        // Добавляем элементы на экран и настраиваем констрейты
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)

        // Настраиваем констрейты
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        let backButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapBackButton))
        navigationItem.rightBarButtonItem = backButton

        loadAndDisplayImage()
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
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: imageURL, placeholder: nil, completionHandler: { [weak self] (result) in
            switch result {
            case .success(_):
                print("Image loaded successfully")
                UIBlockingProgressHUD.dismiss()
                self?.rescaleAndCenterImageInScrollView(image: self?.imageView.image)
            case .failure(let error):
                print("Image loading failed with error: \(error)")
                UIBlockingProgressHUD.dismiss()
                let alert = UIAlertController(title: "Ошибка", message: "Что-то пошло не так. Попробовать ещё раз?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Не надо", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { (_) in
                    self?.loadAndDisplayImage()
                }))
                
                self?.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage?) {
        guard let image = image else {
            return
        }
        
        let scrollViewSize = scrollView.bounds.size
        
        let imageSize = image.size
        
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let scale = max(widthScale, heightScale)
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = max(scale, 3.0)
        
        scrollView.zoomScale = scale
        
        let xOffset = max((scrollView.contentSize.width * scale - scrollViewSize.width) * 0.5, 0)
        let yOffset = max((scrollView.contentSize.height * scale - scrollViewSize.height) * 0.5, 0)
        
        scrollView.contentInset = UIEdgeInsets(top: yOffset, left: xOffset, bottom: 0, right: 0)
    }
}
// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
