//
//  NetworkBuilder.swift
//  GiphyApp
//
//  Created by Guy Twig on 04/04/2024.
//

import Foundation

class NetworkBuilder {
    
    enum ApiUtils {
        case gifbaseUrl
        case apiKey
        
        var description: String {
            switch self {
            case .gifbaseUrl:
                return "https://api.giphy.com/v1/gifs"
            case .apiKey:
                return "?api_key=WzrHZBIvMMkvAcdAy9nu0LNsWp8vgo8f"
            }
        }
    }
    
    enum EndPoints {
        case searchEndpoint
        case trendingEndPoint
        
        var description: String {
            switch self {
            case .searchEndpoint:
                return "/search"
            case .trendingEndPoint:
                return "/trending"
            }
        }
    }
}
