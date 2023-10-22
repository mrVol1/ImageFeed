//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 14/08/2023.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var photo: Photo?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadAndDisplayImage()
        navigationItem.hidesBackButton = true
        tabBarController?.tabBar.isHidden = true
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       // Скрываем навигационный бар
        navigationController?.setNavigationBarHidden(true, animated: false)

       // Скрываем таббар
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        view.addSubview(scrollView)
        scrollView.delegate = self
        
        // Добавляем кнопку "Назад" в верхний левый угол
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        backButton.tintColor = .white
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 55),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Добавляем кнопку "Поделиться" в центр низа экрана
        let shareButton = UIButton(type: .custom)
        shareButton.backgroundColor = .black
        shareButton.layer.cornerRadius = 25 // Радиус делает кнопку круглой
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        view.addSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50), // От низа на 50 пикселей
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Добавляем белую иконку шаринга на кнопку "Поделиться"
        let shareIcon = UIImageView(image: UIImage(systemName: "square.and.arrow.up"))
        shareIcon.tintColor = .white
        shareIcon.contentMode = .scaleAspectFit
        shareButton.addSubview(shareIcon)
        shareIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shareIcon.centerXAnchor.constraint(equalTo: shareButton.centerXAnchor),
            shareIcon.centerYAnchor.constraint(equalTo: shareButton.centerYAnchor),
            shareIcon.widthAnchor.constraint(equalToConstant: 30),
            shareIcon.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Констрейты для scrollView (привязываем к супервью)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // Добавляем изображение внутрь scrollView
        scrollView.addSubview(imageView)
        
        // Констрейты для imageView (изображение занимает весь экран)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor), // Отступ от верхнего края экрана
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),// Отступ от нижнего края экрана
        ])
        
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
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
                UIBlockingProgressHUD.dismiss()
                self?.rescaleAndCenterImageInScrollView(image: self?.imageView.image)
            case .failure(_):
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
    
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapShareButton() {
        if let imageToShare = imageView.image {
            let sharingImage = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
            present(sharingImage, animated: true)
        } else {
            let alertController = UIAlertController(title: "Ошибка", message: "Произошла ошибка, повторите попозже", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
