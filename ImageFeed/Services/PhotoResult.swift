//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Eduard Karimov on 25/09/2023.
//

import Foundation

struct PhotoResult: Codable {
    let photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case photos = "results" 
    }
}

struct Photo: Codable {
    let id: String
    let width: Int
    let height: Int
    let color: String?
    let user: User
    
    enum CodingKeys: String, CodingKey {
            case id
            case width
            case height
            case color
            case user
        }
}

struct User {
    
}
