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
    private var fetchMore: Bool = false
    private var searchString: String?
    private var fetchType: GifType = .trending
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView! {
        didSet {
            loader.startAnimating()
        }
    }
    @IBOutlet weak var noResultsLbl: UILabel!
    @IBOutlet weak var noResultsSearchLbl: UILabel!
    
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
        if indexPath.row >= gifArray.count - 15 && fetchMore {
            vm?.getTrendingGifs(gifType: fetchType, setToZero: false, searchString: searchString)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        return true
    }
}

extension MainVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        fetchType = textField.text?.isEmpty ?? true ? .trending : .serach
        searchString = textField.text
        vm?.getTrendingGifs(gifType: fetchType, setToZero: true, searchString: searchString)
    }
}

extension MainVC: MainVMDelegate {
    func payoadFetched(gifArr: [GifData], totalCount: Int, removeAll: Bool, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            
            if let error {
                self.presentAlert(withTitle: "אירעה שגיאה, אנא נסה שנית מאוחר יותר", message: error.localizedDescription)
            } else {
                let startIndex = self.gifArray.count
                if removeAll {
                    self.gifArray.removeAll()
                    self.gifArray = gifArr
                    self.collectionView.reloadData()
                } else {
                    self.gifArray.append(contentsOf: gifArr)
                    let endIndex = self.gifArray.count - 1
                    let indexPaths = (startIndex...endIndex).map { IndexPath(item: $0, section: 0) }
                    self.collectionView.insertItems(at: indexPaths)
                }
                
                self.fetchMore = gifArray.count < totalCount
                noResultsLbl.isHidden = !gifArray.isEmpty
                noResultsSearchLbl.isHidden = !gifArray.isEmpty
                noResultsSearchLbl.text = gifArray.isEmpty ? "'\(searchString ?? "")'" : ""
                self.loader.stopAnimating()
            }
        }
    }
}
