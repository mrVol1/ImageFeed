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
    func imageListCellDidTapLike(at indexPath: IndexPath)
}

final class ImagesListCell: UITableViewCell {
    weak var delegate: ImagesListCellDelegate?
    var indexPath: IndexPath?
    weak var tableView: UITableView?
    
    static let reuseIdentifier = "ImagesListCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var buttonClick: UIButton!
    @IBOutlet weak var labelView: UILabel!
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        buttonClick.setImage(likeImage, for: .normal)
    }
    
    // MARK: - lIKE Button
    
    @IBAction private func likeButtonClicked() {
        guard let indexPath = indexPath else {
            return
        }
        
        delegate?.imageListCellDidTapLike(at: indexPath)
    }
}
