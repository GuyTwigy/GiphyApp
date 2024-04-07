//
//  GifCell.swift
//  GiphyApp
//
//  Created by Guy Twig on 04/04/2024.
//

import UIKit
import ImageIOUIKit

class GifCell: UICollectionViewCell {
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var gifView: ImageSourceView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loader.startAnimating()
    }
    
    func setupContent(gifdata: GifData) {
        loader.startAnimating()
        gifView.isAnimationEnabled = true
        if let url = URL(string: gifdata.images?.original.url ?? "") {
            gifView.load(url, with: .shared) { [weak self]  _, _,_,_  in
                // in case of error or not loading image loader will continue dispalying
                self?.loader.stopAnimating()
            }
        }
    }
}

