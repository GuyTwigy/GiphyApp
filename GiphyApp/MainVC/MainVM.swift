//
//  TrendingVM.swift
//  GiphyApp
//
//  Created by Guy Twig on 04/04/2024.
//

import Foundation
import Combine

protocol MainVMDelegate: AnyObject {
    func payoadFetched(gifArr: [GifData], totalCount: Int, removeAll: Bool, error: Error?)
}

class MainVM {
    
    enum GifType {
        case trending
        case serach
    }
    
    enum collectionViewState {
        case all
        case favorite
    }
    
    private var gifArray: [GifData] = []
    private var favGifsArray: [GifData] = []
    private var pageCounter: Int = 0
    weak var delegate: MainVMDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        getGifs(gifType: .trending, setToZero: true)
    }
    
    func getGifs(gifType: GifType, setToZero: Bool, searchString: String? = nil) {
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
                        self?.delegate?.payoadFetched(gifArr: [], totalCount: 0, removeAll: setToZero, error: ErrorsHandlers.serverError(.noInternetConnection))
                        return
                    }
                    
                    
                    self.delegate?.payoadFetched(gifArr: gifResponse.data, totalCount: gifResponse.pagination.totalCount, removeAll: setToZero, error: nil)
                }
                .store(in: &cancellables)
        } else {
            delegate?.payoadFetched(gifArr: [], totalCount: 0, removeAll: setToZero, error: ErrorsHandlers.requestError(.invalidData))
        }
    }
    
    func getGifById(id: String, completion: @escaping () -> ()) {
        let queries = "&gif_id=\(id)"
        let urlString = "\(NetworkBuilder.ApiUtils.gifbaseUrl.description)/\(id)\(NetworkBuilder.ApiUtils.apiKey.description)\(queries)"
        if let url = URL(string: urlString) {
            let urlRequest = URLRequest(url: url)
            NetworkManager.shared.genericGetCall(url: urlRequest, type: GifByIdResponse.self)
                .sink { [weak self]  completionResult in
                    guard let self else {
                        self?.delegate?.payoadFetched(gifArr: [], totalCount: 0, removeAll: false, error: ErrorsHandlers.requestError(.invalidRequest(urlRequest)))
                        completion()
                        return
                    }
                    
                    if case .failure(let error) = completionResult {
                        print(ErrorsHandlers.requestError(.other(error)))
                        self.delegate?.payoadFetched(gifArr: [], totalCount: 0, removeAll: false, error: ErrorsHandlers.requestError(.other(error)))
                        completion()
                    }
                } receiveValue: { [weak self] gifResponse in
                    guard let self else {
                        self?.delegate?.payoadFetched(gifArr: [], totalCount: 0, removeAll: false, error: ErrorsHandlers.serverError(.noInternetConnection))
                        return
                    }
                    
                    print("Gif fetched successfuly")
                    favGifsArray.append(gifResponse.data)
                    completion()
                }
                .store(in: &cancellables)
        } else {
            delegate?.payoadFetched(gifArr: [], totalCount: 0, removeAll: false, error: ErrorsHandlers.requestError(.invalidData))
            completion()
        }
    }
    
    func fetchFavorites() {
        favGifsArray.removeAll()
        let favorites = CoreDataManager.sharedInstance.fetchFavoriteGifs()
        getFavArr(favArr: favorites)
    }
    
    func getFavArr(favArr: [GifData]) {
        let dispatchGroup = DispatchGroup()
        for fav in favArr {
            dispatchGroup.enter()
            getGifById(id: fav.id ?? "") {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self else {
                return
            }
            
            print("All getGifById calls have completed.")
            self.delegate?.payoadFetched(gifArr: favGifsArray, totalCount: favGifsArray.count, removeAll: true, error: nil)
        }
    }
    
    func addToFavorite(gifData: GifData) {
        let gifData = GifData(images: nil, id: gifData.id, favorite: true)
        CoreDataManager.sharedInstance.addGifToFavorites(gifData)
    }
    
    func removeFavorite(gifData: GifData) {
        let gifData = GifData(images: nil, id: gifData.id, favorite: false)
        CoreDataManager.sharedInstance.removeGifFromFavorites(gifData)
        fetchFavorites()
    }
}
