//
//  PhotoData.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 25/09/2023.
//

import Foundation

import UIKit

struct Photo: Codable {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let description: String?
    let thumbImageURL: String?
    let largeImageURL: String?
    let isLiked: Bool

    init(photoResult: PhotoResult) {
        id = photoResult.id
        size = CGSize(width: photoResult.width, height: photoResult.height)
        
        if let createdAtDate = photoResult.createdAt {
            createdAt = createdAtDate
        } else {
            createdAt = nil
        }

        
        description = photoResult.description
        thumbImageURL = photoResult.urls.thumb ?? ""
        largeImageURL = photoResult.urls.full ?? ""
        isLiked = photoResult.likedByUser
    }
}


