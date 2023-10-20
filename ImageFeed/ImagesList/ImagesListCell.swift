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
        
        contentView.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        
        // Настройка элементов интерфейса
        cellImage.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellImage)
        
        buttonClick.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonClick)
        
        labelView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(labelView)
        
        // Настройка констрейтов
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            cellImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            cellImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            cellImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            buttonClick.widthAnchor.constraint(equalToConstant: 44),
            buttonClick.heightAnchor.constraint(equalToConstant: 44),
            buttonClick.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: 0),
            buttonClick.topAnchor.constraint(equalTo: cellImage.topAnchor, constant: 0),
            
            labelView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 8),
            labelView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: -8)
        ])
        
        cellImage.layer.cornerRadius = 16
        cellImage.layer.masksToBounds = true
        cellImage.contentMode = .scaleAspectFill

        labelView.textColor = UIColor.white
        labelView.font = UIFont.systemFont(ofSize: 13)
        
        buttonClick.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
    }
    
    //обработчик кнопки
    @objc func likeButtonClicked() {
            isLike = !isLike
            guard let indexPath = indexPath else {
                return
            }
            delegate?.imageListCellDidTapLike(at: indexPath, isLike: isLike)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
