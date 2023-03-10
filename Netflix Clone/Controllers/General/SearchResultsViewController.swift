//
//  SearchResultsViewController.swift
//  Netflix Clone
//
//  Created by Burak on 27.12.2022.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func searchResultsViewControllerDidTapItem(_ viewmodel: MoviePreviewViewModel)
}

class SearchResultsViewController: UIViewController {
    
    public var movies: [Movie] = []
    
    public weak var delegate: SearchResultsViewControllerDelegate?
    
    public let searchResultsCollectionView: UICollectionView = {
           
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3 - 10, height: 200)
            layout.minimumInteritemSpacing = 0

            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
            return collectionView
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(searchResultsCollectionView)
        
        searchResultsCollectionView.delegate = self
        searchResultsCollectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchResultsCollectionView.frame = view.bounds
    }
}

extension SearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as? MovieCollectionViewCell else { return UICollectionViewCell()}
        
        let movie = movies[indexPath.item]
        cell.configure(with: movie.posterPath ?? "")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let movie = movies[indexPath.row]
        
        guard let titleName = movie.title ?? movie.originalTitle else { return }
        
        
        APICaller.shared.getMovie(with: titleName) { [weak self] result in
            switch result {
            case .success(let videoElement):
                let viewmodel = MoviePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: movie.overview ?? "" )
                self?.delegate?.searchResultsViewControllerDidTapItem(viewmodel)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
}
