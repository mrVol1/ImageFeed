//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 14/08/2023.
//

import UIKit
import ProgressHUD
import Kingfisher

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {

    var photo: Photo?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let imageFullView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadAndDisplayImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageFullView)

        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25

        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        imageFullView.contentMode = .scaleAspectFill
        imageFullView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        imageFullView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
    }
    
    func setImage(_ image: UIImage) {
        imageFullView.image = image
    }

    func loadAndDisplayImage() {
        print("Invalid image URL")
        guard let imageURLString = photo?.largeImageURL, let imageURL = URL(string: imageURLString) else {
            return
        }
        
        print("Start loading image from URL: \(imageURL)")

        UIBlockingProgressHUD.show()
        imageFullView.kf.indicatorType = .none
        imageFullView.kf.setImage(with: imageURL, placeholder: nil) { [weak self] (result: Result<RetrieveImageResult, KingfisherError>) in
            switch result {
            case .success(_):
                print("Image loaded successfully")
                UIBlockingProgressHUD.dismiss()
                print("Image size: \(self?.imageFullView.image?.size ?? .zero)")
                print("Before rescale and center")
                self?.rescaleAndCenterImageInScrollView(image: self?.imageFullView.image ?? UIImage())
                print("After rescale and center")
                if let image = self?.imageFullView.image {
                    print("Setting the image in SingleImageViewController")
                    self?.setImage(image)
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
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageFullView
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage?) {
        print("Before rescale and center")
        guard let image = image else {
            return
        }

        let scrollViewSize = scrollView.bounds.size
        let imageSize = image.size
        
        print("ScrollView size: \(scrollViewSize)")
        print("Image size: \(imageSize)")

        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let scale = max(widthScale, heightScale)

        print("Width scale: \(widthScale), Height scale: \(heightScale), Chosen scale: \(scale)")

    
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = max(scale, 3.0)

        scrollView.zoomScale = scale

        let xOffset = max((scrollView.contentSize.width * scale - scrollViewSize.width) * 0.5, 0)
        let yOffset = max((scrollView.contentSize.height * scale - scrollViewSize.height) * 0.5, 0)
        
        print("xOffset: \(xOffset), yOffset: \(yOffset)")

        scrollView.contentInset = UIEdgeInsets(top: yOffset, left: xOffset, bottom: 0, right: 0)
        print("After rescale and center")
    }
}
