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
        downVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.down_vote_red), forState: .Normal)
        downVoteBtn.setFontAwesome(fontAwesome: "f0dd", forState: .Normal)
        
        downVoteBtn.titleLabel?.textAlignment = .Center
        downVoteBtn.titleLabel?.numberOfLines = 1
        
        upVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.up_vote_green), forState: .Normal)
        upVoteBtn.setFontAwesome(fontAwesome: "f0de", forState: .Normal)
        
        upVoteBtn.titleLabel?.textAlignment = .Center
        upVoteBtn.titleLabel?.numberOfLines = 1
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
