//
//  TrendingVM.swift
//  GiphyApp
//
//  Created by Guy Twig on 04/04/2024.
//

import Foundation
import Combine

enum GifType {
    case trending
    case serach
}

protocol MainVMDelegate: AnyObject {
    func terndinfFetched(gifArr: [GifData], totalCount: Int, error: Error?)
}

class MainVM {
    
    var gifArray: [GifData] = []
    weak var delegate: MainVMDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        getTrendingGifs(gifType: .trending)
    }
    
    func getTrendingGifs(page: Int = 0, gifType: GifType) {
        let queries = "&limit=15&offset=\(page * 15)"
        var urlString = String()
        switch gifType {
        case .trending:
            urlString = "\(NetworkBuilder.ApiUtils.gifbaseUrl.description)\(NetworkBuilder.EndPoints.trendingEndPoint.description)\(NetworkBuilder.ApiUtils.apiKey.description)\(queries)"
        case .serach:
            urlString = "\(NetworkBuilder.ApiUtils.gifbaseUrl.description)\(NetworkBuilder.EndPoints.searchEndpoint.description)\(NetworkBuilder.ApiUtils.apiKey.description)\(queries)"
        }
        if let url = URL(string: urlString) {
            let urlRequest = URLRequest(url: url)
            NetworkManager.shared.genericGetCall(url: urlRequest, type: GifResponse.self)
                .sink { [weak self]  completion in
                    guard let self else {
                        self?.delegate?.terndinfFetched(gifArr: [], totalCount: 0, error: ErrorsHandlers.requestError(.invalidRequest(urlRequest)))
                        return
                    }
                    
                    if case .failure(let error) = completion {
                        print(ErrorsHandlers.requestError(.other(error)))
                        self.delegate?.terndinfFetched(gifArr: [], totalCount: 0, error: ErrorsHandlers.requestError(.other(error)))
                    }
                } receiveValue: { [weak self] gifResponse in
                    guard let self else {
                        self?.delegate?.terndinfFetched(gifArr: [], totalCount: 0,  error: ErrorsHandlers.serverError(.noInternetConnection))
                        return
                    }
                    
                    
                    self.delegate?.terndinfFetched(gifArr: gifResponse.data, totalCount: gifResponse.pagination.totalCount, error: nil)
                }
                .store(in: &cancellables)
        } else {
            delegate?.terndinfFetched(gifArr: [], totalCount: 0, error: ErrorsHandlers.requestError(.invalidData))
        }
    }
}
