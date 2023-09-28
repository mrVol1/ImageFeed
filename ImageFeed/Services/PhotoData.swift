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
    let width: Int
    let height: Int
    let size: CGSize
    let createdAt: Date?
    let description: String?
    let thumbImageURL: String?
    let largeImageURL: String?
    let isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case description
        case thumbImageURL = "thumb"
        case largeImageURL = "raw"
        case isLiked = "liked_by_user"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        size = CGSize(width: width, height: height)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        thumbImageURL = try container.decodeIfPresent(String.self, forKey: .thumbImageURL)
        largeImageURL = try container.decodeIfPresent(String.self, forKey: .largeImageURL)
        isLiked = try container.decode(Bool.self, forKey: .isLiked)
    }
}
