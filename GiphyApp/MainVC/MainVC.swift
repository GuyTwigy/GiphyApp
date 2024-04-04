//
//  MainVC.swift
//  GiphyApp
//
//  Created by Guy Twig on 04/04/2024.
//

import UIKit

class MainVC: UIViewController {

    private var vm: MainVM?
    private var gifArray: [GifData] = []
    private var firstLoad: Bool = true
    private var fetchMore: Bool = false
    private var pageCounter: Int = 0
    private var fetchType: GifType = .trending
    
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
        cell.setupContent(gifdata: gifArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // make favorite
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row >= gifArray.count - 150 && fetchMore {
            pageCounter += 1
            firstLoad = false
            switch fetchType {
            case .trending:
                vm?.getTrendingGifs(page: pageCounter, gifType: .trending)
            case .serach:
                vm?.getTrendingGifs(page: pageCounter, gifType: .serach)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchTextField.resignFirstResponder()
    }
}

extension MainVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        fetchType = textField.text?.isEmpty ?? true ? .trending : .serach
    }
}

extension MainVC: MainVMDelegate {
    func terndinfFetched(gifArr: [GifData], totalCount: Int, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            
            if let error {
                self.presentAlert(withTitle: "אירעה שגיאה, אנא נסה שנית מאוחר יותר", message: error.localizedDescription)
            } else {
                if firstLoad {
                    self.gifArray.removeAll()
                    self.gifArray = gifArr
                } else {
                    self.gifArray.append(contentsOf: gifArr)
                }
                
                self.fetchMore = gifArray.count < totalCount
                self.collectionView.reloadData()
                self.loader.stopAnimating()
            }
        }
    }
}
