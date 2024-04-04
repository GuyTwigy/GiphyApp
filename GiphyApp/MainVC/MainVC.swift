//
//  MainVC.swift
//  GiphyApp
//
//  Created by Guy Twig on 04/04/2024.
//

import UIKit

class MainVC: UIViewController {

    var vm: MainVM?
    var gifArray: [GifData] = []
    var firstLoad: Bool = true
    var fetchMore: Bool = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView! {
        didSet {
            loader.startAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = MainVM()
        vm?.delegate = self
        setupCollectionView()
        setupTextField()
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(UINib(nibName: "GifCell", bundle: nil), forCellWithReuseIdentifier: "GifCell")
    }
    
    func setupTextField() {
        searchTextField.delegate = self
    }
    
    func createLayout() -> UICollectionViewLayout {
        var itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalWidth(1/3))
        var groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/3))
        if UIDevice.current.userInterfaceIdiom == .pad {
            itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/6), heightDimension: .fractionalWidth(1/6))
            groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/6))
        }
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        gifArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GifCell", for: indexPath) as! GifCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // make favorite
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
       // fetch more data
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchTextField.resignFirstResponder()
    }
}

extension MainVC: UITextFieldDelegate {
    
}

extension MainVC: MainVMDelegate {
    func terndinfFetched(gifArr: [GifData], totalCount: Int, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            
            if let error {
                // show error alert
            } else {
                if firstLoad {
                    self.gifArray.removeAll()
                    self.gifArray = gifArr
                } else {
                    self.gifArray.append(contentsOf: gifArr)
                }
                
                fetchMore = gifArray.count < totalCount
                self.collectionView.reloadData()
                self.loader.stopAnimating()
            }
        }
    }
}
