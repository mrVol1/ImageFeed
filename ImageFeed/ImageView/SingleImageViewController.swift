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
}
// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
