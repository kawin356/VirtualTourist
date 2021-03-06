//
//  MapImageCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Kittikawin Sontinarakul on 19/4/2563 BE.
//  Copyright © 2563 Kittikawin Sontinarakul. All rights reserved.
//

import UIKit

class MapImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIncicator: UIActivityIndicatorView!
    
    func configImage(image: UIImage) {
        imageView.image = image
    }
    
    override var isSelected: Bool {
      didSet {
        imageView.layer.borderWidth = isSelected ? 10 : 0
      }
    }
    
    override func awakeFromNib() {
      super.awakeFromNib()
        imageView.layer.borderColor = UIColor.red.cgColor
      isSelected = false
    }
}
