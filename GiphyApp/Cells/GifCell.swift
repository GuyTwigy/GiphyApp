//
//  GifCell.swift
//  GiphyApp
//
//  Created by Guy Twig on 04/04/2024.
//

import UIKit
import ImageIOUIKit

protocol GifCellDelegate: AnyObject {
    func cellTapped(gif: GifData, state: MainVM.collectionViewState)
}

class GifCell: UICollectionViewCell {
    
    private var gif: GifData?
    private var state: MainVM.collectionViewState?
    weak var delegate: GifCellDelegate?
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var gifView: ImageSourceView!
    @IBOutlet weak var favoriteImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gifView.task?.cancel()
        favoriteImage.isHidden = true
        gif = nil
        delegate = nil
        state = nil
        loader.startAnimating()
    }
    
    func setupContent(gifdata: GifData, collectionState: MainVM.collectionViewState) {
        loader.startAnimating()
        state = collectionState
        gif = gifdata
        gifView.isAnimationEnabled = true
        if let url = URL(string: gifdata.images?.fixedHeightDownsampled.url ?? "") {
            gifView.load(url, with: .shared) { [weak self]  _, _,_,_  in
                // in case of error or not loading image loader will continue dispalying
                self?.loader.stopAnimating()
            }
        }
    }
    
    func animationForFavotite() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            guard let self else {
                return
            }
            
            self.favoriteImage.isHidden = false
            self.favoriteImage.transform = CGAffineTransform(rotationAngle: .pi)
        }) { [weak self] _ in
            guard let self else {
                return
            }
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                self.favoriteImage.transform = .identity
            }) { _ in
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                    self.favoriteImage.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }) { _ in
                    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                        self.favoriteImage.transform = .identity
                    }) { _ in
                        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                            self.favoriteImage.alpha = 0
                        })
                    }
                }
            }
        }
    }
    
    @IBAction func cellTapped(_ sender: Any) {
        if let gif, let state {
            switch state {
            case .all:
                animationForFavotite()
            case .favorite:
                break
            }
            delegate?.cellTapped(gif: gif, state: state)
        }
    }
}

