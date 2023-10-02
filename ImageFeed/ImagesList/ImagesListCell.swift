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
    
    static let reuseIdentifier = "ImagesListCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
    }
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var buttonClick: UIButton!
    @IBOutlet weak var labelView: UILabel!
    
    // MARK: - lIKE Button
    
    @IBAction private func likeButtonClicked() {
        isLike = !isLike
        guard let indexPath = indexPath else {
            return
        }
        
        delegate?.imageListCellDidTapLike(at: indexPath, isLike: isLike)
    }
}
