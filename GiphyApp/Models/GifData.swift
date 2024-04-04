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

struct GifData: Codable {
    let images: Images
    let id: String
}

struct Pagination: Codable {
    let total_count: Int
    let count: Int
}

struct Images: Codable {
    let original: Original
}

struct Original: Codable {
    let url: String
}

