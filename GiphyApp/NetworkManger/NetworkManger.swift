//
//  NetworkManger.swift
//  GiphyApp
//
//  Created by Guy Twig on 04/04/2024.
//

import Foundation
import Combine

class NetworkManager {
    
    static let shared = NetworkManager()
    private var cancellables = Set<AnyCancellable>()
    
    func genericGetCall<T: Codable>(url: URLRequest, type: T.Type) -> Future<T, Error> {
        var request = url
        request.httpMethod = "GET"
        
        return Future<T, Error> { [weak self] promise in
            guard let self else {
                return promise(.failure(ErrorsHandlers.requestError(.invalidRequest(request))))
            }
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { res in
                    guard let response = res.response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode <= 300 else {
                        throw ErrorsHandlers.serverError(.invalidStatusCode("Invalid status code"))
                    }
                    
                    let decoder = JSONDecoder()
                    guard let finalData = try? decoder.decode(T.self, from: res.data) else {
                        throw ErrorsHandlers.requestError(.decodingError("Fail to decode"))
                    }
                    
                    return finalData
                }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (completion) in
                    if case let .failure(err) = completion {
                        switch err {
                        case let decodingerror as DecodingError:
                            promise(.failure(decodingerror))
                        case let apiError as ErrorsHandlers:
                            promise(.failure(apiError))
                        default:
                            promise(.failure(ErrorsHandlers.serverError(.noInternetConnection)))
                        }
                    }
                }, receiveValue: {
                    promise(.success($0))
                })
                .store(in: &self.cancellables)
        }
    }
}

