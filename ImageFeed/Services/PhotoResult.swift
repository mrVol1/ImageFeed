//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 25/09/2023.
//

import Foundation

struct PhotoResult: Codable {
    let id: String
    let createdAt: Date
    let updatedAt: String
    let width: Int
    let height: Int
    let color: String
    let blurHash: String
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    struct UrlsResult: Codable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let date = dateFormatter.date(from: createdAtString) {
            createdAt = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Date string does not match format expected by formatter.")
        }
        
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        color = try container.decode(String.self, forKey: .color)
        blurHash = try container.decode(String.self, forKey: .blurHash)
        likes = try container.decode(Int.self, forKey: .likes)
        likedByUser = try container.decode(Bool.self, forKey: .likedByUser)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        urls = try container.decode(UrlsResult.self, forKey: .urls)
    }
}
