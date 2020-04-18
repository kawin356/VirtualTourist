//
//  OnboardingCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Kittikawin Sontinarakul on 18/4/2563 BE.
//  Copyright © 2563 Kittikawin Sontinarakul. All rights reserved.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageSlide: UIImageView!
    
    func configImage(image: UIImage) {
        imageSlide.image = image
    }
}
