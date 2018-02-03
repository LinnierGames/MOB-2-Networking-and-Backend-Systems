//
//  CustomTableViewCell.swift
//  Product-Hunt
//
//  Created by Erick Sanchez on 2/2/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelTagline: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var captionVotes: UILabel!
    @IBOutlet weak var captionComments: UILabel!
    @IBOutlet weak var captionUser: UILabel!
    
    func configure(post: Product) {
        
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
