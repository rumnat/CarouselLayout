//
//  ImageCell.swift
//  CarouselLayout
//
//  Created by Anton Muratov on 10/9/18.
//  Copyright © 2018 Anton Muratov. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 15
        
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowRadius = 20.0
        imageView.layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
        imageView.layer.shadowOpacity = 0.5
        
    }
}
