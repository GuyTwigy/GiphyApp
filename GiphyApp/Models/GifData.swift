//
//  GifData.swift
//  GiphyApp
//
//  Created by Guy Twig on 04/04/2024.
//

import Foundation

struct GifResponse: Codable {
    let data: [GifData]
    let pagination: Pagination
}

struct GifByIdResponse: Codable {
    let data: GifData
}

struct GifData: Codable {
    let images: Images?
    let id: String?
}

struct Pagination: Codable {
    let count: Int
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case count
        case totalCount = "total_count"
    }
    
    init(count: Int, totalCount: Int) {
        self.count = count
        self.totalCount = totalCount
    }
}

struct Images: Codable {
    let original: Original
}

struct Original: Codable {
    let url: String
}

