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
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
    }
    
    init(totalCount: Int) {
        self.totalCount = totalCount
    }
}

struct Images: Codable {
    let fixedHeightDownsampled: FixedHeightDownsampled
    
    enum CodingKeys: String, CodingKey {
        case fixedHeightDownsampled = "fixed_height_downsampled"
    }
    
    init(fixedHeightDownsampled: FixedHeightDownsampled) {
        self.fixedHeightDownsampled = fixedHeightDownsampled
    }
}

struct FixedHeightDownsampled: Codable {
    let url: String?
}
