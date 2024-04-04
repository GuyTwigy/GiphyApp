//
//  TrendingVM.swift
//  GiphyApp
//
//  Created by Guy Twig on 04/04/2024.
//

import Foundation

protocol MainVMDelegate: AnyObject {
    func terndinfFetched()
}

class MainVM {
    
    weak var delegate: MainVMDelegate?
    
    init() {
        getTrendingGifs()
    }
        
    
    func getTrendingGifs() {
            
    }
}
