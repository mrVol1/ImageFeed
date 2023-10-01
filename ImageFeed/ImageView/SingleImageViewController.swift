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
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        loadAndDisplayImage()
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        let sharingImage = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        present(sharingImage, animated: true)
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
        let safeAreaInsets = view.safeAreaInsets
        let availableWidth = scrollViewSize.width
        let availableHeight = scrollViewSize.height - safeAreaInsets.top - safeAreaInsets.bottom
        
        let imageSize = image.size
        let widthScale = availableWidth / imageSize.width
        let heightScale = availableHeight / imageSize.height
        let scale = max(widthScale, heightScale)
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = max(scale, 3.0)
        
        scrollView.zoomScale = scale
        
        let xOffset = max(0, (scrollView.contentSize.width * scale - availableWidth) / 2)
        let yOffset = max(0, (scrollView.contentSize.height * scale - availableHeight) / 2)
        
        scrollView.contentInset = UIEdgeInsets(top: safeAreaInsets.top, left: 0, bottom: safeAreaInsets.bottom, right: 0)
        scrollView.contentOffset = CGPoint(x: xOffset, y: yOffset)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
