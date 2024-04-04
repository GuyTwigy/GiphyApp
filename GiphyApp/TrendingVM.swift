//
//  TrendingVM.swift
//  GiphyApp
//
//  Created by Guy Twig on 04/04/2024.
//

import Foundation

protocol TrendingVMDelegate: AnyObject {
    func terndinfFetched()
}

class TrendingVM {
    
    weak var delegate: TrendingVMDelegate?
    
    init() {
        getTrendingGifs()
    }
        
    
    func getTrendingGifs() {
            
    }
}
