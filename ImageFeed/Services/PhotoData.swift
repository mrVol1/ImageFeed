//
//  PhotoData.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 25/09/2023.
//

import Foundation

public struct Photo: Codable {
    let id: String
    let width: Int
    let height: Int
    let size: CGSize
    let createdAt: Date?
    let description: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case description
        case urls
        case thumbImageURL = "small"
        case largeImageURL = "full"
        case isLiked = "liked_by_user"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        size = CGSize(width: width, height: height)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        let urlsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .urls)
        thumbImageURL = try urlsContainer.decode(String.self, forKey: .thumbImageURL)
        largeImageURL = try urlsContainer.decode(String.self, forKey: .largeImageURL)
        isLiked = try container.decode(Bool.self, forKey: .isLiked)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(description, forKey: .description)
        var urlsContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .urls)
        try urlsContainer.encode(thumbImageURL, forKey: .thumbImageURL)
        try urlsContainer.encode(largeImageURL, forKey: .largeImageURL)
        try container.encode(isLiked, forKey: .isLiked)
    }
}
