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
        var buttonStringDn = String.fontAwesomeString("fa-sort-down")
        var buttonStringAttributedDn = NSMutableAttributedString(string: buttonStringDn, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 11.00)!])
        buttonStringAttributedDn.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize("FontAwesome", fontSize: 20), range: NSRange(location: 0,length: 1))
        
        downVoteBtn.titleLabel?.textAlignment = .Center
        downVoteBtn.titleLabel?.numberOfLines = 1
        downVoteBtn.setAttributedTitle(buttonStringAttributedDn, forState: .Normal)
        
        var buttonStringUp = String.fontAwesomeString("fa-sort-up")
        var buttonStringAttributedUp = NSMutableAttributedString(string: buttonStringUp, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 11.00)!])
        buttonStringAttributedUp.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize("FontAwesome", fontSize: 20), range: NSRange(location: 0,length: 1))
        
        upVoteBtn.titleLabel?.textAlignment = .Center
        upVoteBtn.titleLabel?.numberOfLines = 1
        upVoteBtn.setAttributedTitle(buttonStringAttributedUp, forState: .Normal)
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
