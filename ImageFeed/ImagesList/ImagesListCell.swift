//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 04/08/2023.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
     
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var buttonClick: UIButton!
    @IBOutlet weak var labelView: UILabel!
}
