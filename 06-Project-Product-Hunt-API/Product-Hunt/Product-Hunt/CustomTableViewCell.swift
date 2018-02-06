//
//  CustomTableViewCell.swift
//  Product-Hunt
//
//  Created by Erick Sanchez on 2/2/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import Kingfisher

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var captionVotes: UILabel!
    @IBOutlet weak var captionComments: UILabel!
    @IBOutlet weak var captionUser: UILabel!
    
    func configure(post: Product) {
        self.labelTitle.text = post.name
        self.labelSubtitle.text = post.tagline
        self.captionVotes.text = String(post.votes)
        self.captionComments.text = String(post.commentCount)
        self.captionUser.text = post.user.username
        self.thumbnail.kf.setImage(with: post.thumbnail.imageUrl)
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
