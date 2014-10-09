//
//  TweetCell.swift
//  TwitClone
//
//  Created by Nathan Birkholz on 10/7/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//
//  Much cribbing from Somon Ng at http://www.appcoda.com/self-sizing-cells/
//

import UIKit

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var userView: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


