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

    @IBAction func upVoteClicked(sender: UIButton) {
        //voteProcess(sender, 1)
        var cell: UITableViewCell = sender.superview?.superview as! UITableViewCell
        var table: UITableView = cell.superview as! UITableView
        //let textFieldIndexPath = table.indexPathForCell(cell)
        //Yellr.println(textFieldIndexPath?.row)
        Yellr.println(cell)

        var postID : String = String(sender.tag)
        //post(["post_id":postID, "is_up_vote":"1"], "register_vote") { (succeeded: Bool, msg: String) -> () in
//            var alert = UIAlertView(title: "Success!", message: msg, delegate: nil, cancelButtonTitle: "Okay.")
//            if(succeeded) {
//                alert.title = "Success!"
//                alert.message = msg
//            }
//            else {
//                alert.title = "Failed : ("
//                alert.message = msg
//            }
//
//            // Move to the UI thread
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                // Show the alert
//                //alert.show()
//            })
        //}
    }
    
    @IBAction func downVoteCLicked(sender: UIButton) {
//        var postID : String = String(sender.tag)
//        post(["post_id":postID, "is_up_vote":"1"], "register_vote") { (succeeded: Bool, msg: String) -> () in
//
//        }
    }

    
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
