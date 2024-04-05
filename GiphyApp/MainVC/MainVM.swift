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
    func payoadFetched(gifArr: [GifData], totalCount: Int, removeAll: Bool, error: Error?)
}

class MainVM {
    
    var gifArray: [GifData] = []
    var pageCounter: Int = 0
    weak var delegate: MainVMDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        getTrendingGifs(gifType: .trending, setToZero: true)
    }
    
    func getTrendingGifs(gifType: GifType, setToZero: Bool, searchString: String? = nil) {
        pageCounter = setToZero ? 0 : pageCounter + 1
        let queries = "&limit=15&offset=\(pageCounter * 15)"
        var urlString = String()
        switch gifType {
        case .trending:
            urlString = "\(NetworkBuilder.ApiUtils.gifbaseUrl.description)\(NetworkBuilder.EndPoints.trendingEndPoint.description)\(NetworkBuilder.ApiUtils.apiKey.description)\(queries)"
        case .serach:
            let searchQuery = "&q=\(searchString ?? "")"
            urlString = "\(NetworkBuilder.ApiUtils.gifbaseUrl.description)\(NetworkBuilder.EndPoints.searchEndpoint.description)\(NetworkBuilder.ApiUtils.apiKey.description)\(queries)\(searchQuery)"
        }
        if let url = URL(string: urlString) {
            let urlRequest = URLRequest(url: url)
            NetworkManager.shared.genericGetCall(url: urlRequest, type: GifResponse.self)
                .sink { [weak self]  completion in
                    guard let self else {
                        self?.delegate?.payoadFetched(gifArr: [], totalCount: 0, removeAll: setToZero, error: ErrorsHandlers.requestError(.invalidRequest(urlRequest)))
                        return
                    }
                    
                    if case .failure(let error) = completion {
                        print(ErrorsHandlers.requestError(.other(error)))
                        self.delegate?.payoadFetched(gifArr: [], totalCount: 0, removeAll: setToZero, error: ErrorsHandlers.requestError(.other(error)))
                    }
                } receiveValue: { [weak self] gifResponse in
                    guard let self else {
                        self?.delegate?.payoadFetched(gifArr: [], totalCount: 0, removeAll: setToZero,  error: ErrorsHandlers.serverError(.noInternetConnection))
                        return
                    }
                    
                    
                    self.delegate?.payoadFetched(gifArr: gifResponse.data, totalCount: gifResponse.pagination.totalCount, removeAll: setToZero, error: nil)
                }
                .store(in: &cancellables)
        } else {
            delegate?.payoadFetched(gifArr: [], totalCount: 0, removeAll: setToZero, error: ErrorsHandlers.requestError(.invalidData))
        }
    }
}
