//
//  AlbumCell.swift
//  ejercicio SISU
//
//  Created by Emmanuel Valentín Granados López on 05/04/18.
//  Copyright © 2018 Emmanuel Valentín Granados López. All rights reserved.
//

import UIKit

class AlbumCell: UITableViewCell {

    @IBOutlet weak var nombreAlbumlbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
