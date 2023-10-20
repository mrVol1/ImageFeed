//
//  FullSingleImageViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 20/10/2023.
//

import Foundation
import UIKit

final class FullSingleImageViewController: UIViewController {
    private let imageFullView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rescaleAndCenterImageInScrollView(image: imageFullView.image)
    }
    
    func setImage(_ image: UIImage) {
        imageFullView.image = image
    }
    
    private func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageFullView)
        
        // Устанавливаем ограничения scrollView относительно родительского view
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // Настраиваем contentMode
        imageFullView.contentMode = .scaleAspectFill
        
        // Устанавливаем ограничения imageFullView относительно scrollView
        imageFullView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        imageFullView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        imageFullView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        imageFullView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        imageFullView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        imageFullView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        
        // Устанавливаем минимальное и максимальное увеличение
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    func rescaleAndCenterImageInScrollView(image: UIImage?) {
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
