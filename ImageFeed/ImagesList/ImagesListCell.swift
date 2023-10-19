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

class ImagesListCell: UITableViewCell {
    let cellImage = UIImageView()
    let buttonClick = UIButton()
    let labelView = UILabel()
    var isLike: Bool = false
    var indexPath: IndexPath?
    weak var delegate: ImagesListCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Настройка элементов интерфейса
        cellImage.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellImage)
        
        buttonClick.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonClick)
        
        labelView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(labelView)
        
        // Настройка констрейтов
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: topAnchor),
            cellImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellImage.bottomAnchor.constraint(equalTo: bottomAnchor),
            cellImage.widthAnchor.constraint(equalTo: widthAnchor),
            
            buttonClick.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            buttonClick.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            labelView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8),
            labelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        ])
        //обработчик кнопки
        func likeButtonClicked() {
            isLike = !isLike
            guard let indexPath = indexPath else {
                return
            }
            delegate?.imageListCellDidTapLike(at: indexPath, isLike: isLike)
        }

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
