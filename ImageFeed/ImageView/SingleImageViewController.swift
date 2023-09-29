//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 14/08/2023.
//

import Foundation
import UIKit

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
        let sharingImage = UIActivityViewController(activityItems: [photo!], applicationActivities: nil)
        present(sharingImage, animated: true)
    }
    
    private func loadAndDisplayImage() {
        guard let imageURLString = photo?.largeImageURL, let imageURL = URL(string: imageURLString) else {
            return
        }
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: imageURL, placeholder: UIImage(named: "placeholder_image"), completionHandler: { [weak self] (result) in
            switch result {
            case .success(_):
                self?.rescaleAndCenterImageInScrollView(image: self?.imageView.image)
            case .failure(let error):
                print("Ошибка при загрузке изображения: \(error)")
            }
        })
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage?) {
        guard image != nil else {
            return
        }
        
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        let scale = max(minZoomScale, maxZoomScale)
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        view.layoutIfNeeded()
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
