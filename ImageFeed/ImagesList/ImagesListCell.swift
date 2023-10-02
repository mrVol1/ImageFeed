//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 04/08/2023.
//

import Foundation
import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(at indexPath: IndexPath, isLike: Bool)
}

final class ImagesListCell: UITableViewCell {
    weak var delegate: ImagesListCellDelegate?
    var indexPath: IndexPath?
    weak var tableView: UITableView?
    var isLike: Bool = false
    var animationLayers = Set<CALayer>()
    
    static let reuseIdentifier = "ImagesListCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var buttonClick: UIButton!
    @IBOutlet weak var labelView: UILabel!
    
    
    // MARK: - Animation
    
    private let gradientLayer = CAGradientLayer()
    
    internal var isAnimationEnabled: Bool = true {
        didSet {
            gradientLayer.isHidden = !isAnimationEnabled
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
        registerForNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupGradient() {
        gradientLayer.frame = cellImage.bounds
        gradientLayer.locations = [0, 0.1, 0.3]
        gradientLayer.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 0.5).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 0.5).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 0.5).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        cellImage.layer.addSublayer(gradientLayer)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientLayer.add(gradientChangeAnimation, forKey: "locationsChange")
        animationLayers.insert(gradientLayer)
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidChangeNotification), name: ImagesListService.DidChangeNotification, object: nil)
    }
    
    @objc private func handleDidChangeNotification() {
        isAnimationEnabled = false
    }
    
    // MARK: - lIKE Button
    
    @IBAction private func likeButtonClicked() {
        isLike = !isLike
        guard let indexPath = indexPath else {
            return
        }
        
        delegate?.imageListCellDidTapLike(at: indexPath, isLike: isLike)
    }
}
