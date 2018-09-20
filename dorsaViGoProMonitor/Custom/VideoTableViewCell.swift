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
    
    func setVideoTableViewCell(file: String){
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
