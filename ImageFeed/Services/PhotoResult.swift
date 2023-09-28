//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 25/09/2023.
//

import Foundation

struct PhotoResult: Codable {
    let id: String
    let createdAt: Date?
    let updatedAt: Date?
    let width: Int
    let height: Int
    let color: String
    let blurHash: String
    let description: String?
    let urls: UrlsResult?
    let likes: Int
    let likedByUser: Bool
    
    struct UrlsResult: Codable {
        let raw: String?
        let full: String?
        let regular: String?
        let small: String?
        let thumb: String?
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width
        case height
        case color
        case blurHash = "blur_hash"
        case description
        case urls
        case likes
        case likedByUser = "liked_by_user"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        color = try container.decode(String.self, forKey: .color)
        blurHash = try container.decode(String.self, forKey: .blurHash)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        urls = try container.decodeIfPresent(UrlsResult.self, forKey: .urls)!
        likes = try container.decode(Int.self, forKey: .likes)
        likedByUser = try container.decode(Bool.self, forKey: .likedByUser)
    }
}
