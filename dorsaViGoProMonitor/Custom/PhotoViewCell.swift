//
//  PhotoViewCell.swift
//  dorsaViGoProMonitor
//
//  Created by Jingyi LI on 21/9/18.
//  Copyright © 2018 dorsaVi Hardware. All rights reserved.
//

import UIKit

class PhotoViewCell: UICollectionViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellName: UILabel!
    
    func setPhotoCell(_ image: UIImage, name: String) {
        cellImage.image = image
        cellName.text = name
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
