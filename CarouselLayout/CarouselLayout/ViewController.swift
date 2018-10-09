//
//  ViewController.swift
//  CarouselLayout
//
//  Created by Anton Muratov on 10/9/18.
//  Copyright © 2018 Anton Muratov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var imagesDataSource: [UIImage] = []
    private let cellIdentifier = "ImageCell"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: 200.0, height: 200.0)
    }
    
    private func setupDataSource() {
        let images = [#imageLiteral(resourceName: "ic_1"), #imageLiteral(resourceName: "ic_2"), #imageLiteral(resourceName: "ic_3"), #imageLiteral(resourceName: "ic_4"), #imageLiteral(resourceName: "ic_5")]
        imagesDataSource.append(contentsOf: images)
        imagesDataSource.append(contentsOf: images)
        imagesDataSource.append(contentsOf: images)
        imagesDataSource.append(contentsOf: images)
        imagesDataSource.append(contentsOf: images)
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ImageCell
        cell.imageView.image = imagesDataSource[indexPath.row]
        return cell
    }
}
