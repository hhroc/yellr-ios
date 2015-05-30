//
//  LocalTableViewCell.swift
//  Yellr
//
//  Created by Debjit Saha on 5/30/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit

class LocalTableViewCell: UITableViewCell {

    @IBOutlet weak var upVoteBtn: UIButton!
    @IBOutlet weak var downVoteBtn: UIButton!
    
    @IBOutlet weak var upVoteCount: UILabel!
    @IBOutlet weak var downVoteCount: UILabel!
    @IBOutlet weak var postedBy: UILabel!
    @IBOutlet weak var postedOn: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var mediaContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
