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
    private var fetchType: MainVM.GifType = .trending
    private var collectionState: MainVM.collectionViewState = .all
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView! {
        didSet {
            loader.startAnimating()
        }
    }
    @IBOutlet weak var noResultsLbl: UILabel!
    @IBOutlet weak var noResultsSearchLbl: UILabel!
    @IBOutlet weak var btnFavorites: UIButton!
    @IBOutlet weak var titleFavovitesLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = MainVM()
        vm?.delegate = self
        setupCollectionView()
        setupTextField()
        addRefreshControl(to: collectionView, action: #selector(refreshData))
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
    
    func flipAndHideContentView() {
        UIView.transition(with: collectionView, duration: 0.5, options: .transitionFlipFromLeft, animations: { [weak self] in
            guard let self else {
                return
            }
            
            self.gifArray.removeAll()
            self.collectionView.reloadData()
        })
    }
    
    @IBAction func favoriteBtnTapped(_ sender: Any) {
        loader.startAnimating()
        collectionState = collectionState == .all ? .favorite : .all
        switch collectionState {
        case .all:
            btnFavorites.setTitle("למועדפים", for: .normal)
            searchTextField.isHidden = false
            titleFavovitesLbl.isHidden = true
            flipAndHideContentView()
            vm?.getGifs(gifType: fetchType, setToZero: true, searchString: searchString)
        case .favorite:
            searchTextField.resignFirstResponder()
            btnFavorites.setTitle("בחזרה למסך הראשי", for: .normal)
            searchTextField.isHidden = true
            titleFavovitesLbl.isHidden = false
            flipAndHideContentView()
            vm?.fetchFavorites()
        }
    }
    
    @objc private func refreshData() {
        switch collectionState {
        case .all:
            vm?.getGifs(gifType: fetchType, setToZero: true, searchString: searchString)
        case .favorite:
            vm?.fetchFavorites()
        }
    }
}

extension MainVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        gifArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GifCell", for: indexPath) as! GifCell
        cell.delegate = self
        cell.setupContent(gifdata: gifArray[indexPath.row], collectionState: collectionState)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch collectionState {
        case .all:
            if indexPath.row >= gifArray.count - 3 && fetchMore {
                vm?.getGifs(gifType: fetchType, setToZero: false, searchString: searchString)
            }
        case .favorite:
            break
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
        vm?.getGifs(gifType: fetchType, setToZero: true, searchString: searchString)
    }
}

extension MainVC: MainVMDelegate {
    func gifAlreadyAdded() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            
            self.presentAlert(withTitle: "ג׳יפ זה נמצא ברשימת המועדפים שלך", message: "")
        }
    }
    
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
                    if startIndex <= endIndex {
                        let indexPaths = (startIndex...endIndex).map { IndexPath(item: $0, section: 0) }
                        self.collectionView.insertItems(at: indexPaths)
                    }
                }
                
                self.fetchMore = self.gifArray.count < totalCount
                switch self.collectionState {
                case .all:
                    self.noResultsLbl.isHidden = !self.gifArray.isEmpty
                    self.noResultsSearchLbl.isHidden = !self.gifArray.isEmpty
                    self.noResultsSearchLbl.text = self.gifArray.isEmpty ? "'\(self.searchString ?? "")'" : ""
                case .favorite:
                    self.noResultsLbl.isHidden = true
                    self.noResultsSearchLbl.isHidden = !self.gifArray.isEmpty
                    self.noResultsSearchLbl.text = "Favorite Is Empty"
                }
            }
            self.endRefreshing(scrollView: self.collectionView)
            self.loader.stopAnimating()
        }
    }
}

extension MainVC: GifCellDelegate {
    func cellTapped(gif: GifData, state: MainVM.collectionViewState) {
        // make favorite
         switch state {
         case .all:
             vm?.addToFavorite(gifData: gif)
         case .favorite:
             presentAlertWithAction(withTitle: "האם ברצונך להסיר מרשימת המועדפים?", message: "") { [weak self] in
                 guard let self else {
                     return
                 }
                 
                 self.loader.startAnimating()
                 self.vm?.removeFavorite(gifData: gif)
             }
         }
    }
}
