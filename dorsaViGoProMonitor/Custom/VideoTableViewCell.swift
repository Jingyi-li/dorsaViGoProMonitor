//
//  VideoTableViewCell.swift
//  dorsaViGoProMonitor
//
//  Created by Jingyi LI on 20/9/18.
//  Copyright © 2018 dorsaVi Hardware. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var videoNameLable: UILabel!
    @IBOutlet weak var fileImage: UIImageView!
    
    func setVideoTableViewCell(file: String, type: String){
        if type == "Local"{
            fileImage.image = UIImage(named: "video-player-local")
        }
        if type == "gopro"{
            fileImage.image = UIImage(named: "video-player-download")
        }
        videoNameLable.text = file
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
