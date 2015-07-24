//
//  LocalPostDetailViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 6/10/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import Foundation
import UIKit

class LocalPostDetailViewController: UIViewController {
    
    var story: String!
    var lname: String!
    var fname: String!
    var publishedOn: String!
    var content: String!
    var storyId:Int!
    var lat: String = ""
    var long: String = ""
    var hasVoted: String = ""
    var isUpVote: String = ""

    @IBOutlet weak var postedBy: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postedOn: UILabel!
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var upVoteCount: UILabel!
    @IBOutlet weak var downVoteCount: UILabel!
    
    @IBOutlet weak var upVoteBtn: UIButton!
    @IBOutlet weak var downVoteBtn: UIButton!
    @IBOutlet weak var reportPost: UIButton!
    
    @IBAction func reportPost(sender: AnyObject) {
        post(["post_id":String(storyId)], "flag_post", self.lat, self.long) { (succeeded: Bool, msg: String) -> () in
            Yellr.println(msg)
            
        }
        if(iOS8) {
            
            let alertController = UIAlertController(title: NSLocalizedString(YellrConstants.LocalPostDetail.ReportTitle, comment: "Local post detail Screen - alert title"), message:
                NSLocalizedString(YellrConstants.LocalPostDetail.ReportMessage, comment: "Local post detail Screen - alert message"), preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString(YellrConstants.LocalPostDetail.ReportOkay, comment: "Local post detail Screen - okay"), style: UIAlertActionStyle.Default, handler: { (action) in
                    //move back to table view
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
                ))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            
            let alert = UIAlertView()
            alert.tag = 0
            alert.delegate = self
            alert.title = NSLocalizedString(YellrConstants.LocalPostDetail.ReportTitle, comment: "Local post detail Screen - alert title")
            alert.message = NSLocalizedString(YellrConstants.LocalPostDetail.ReportMessage, comment: "Local post detail Screen - alert message")
            alert.addButtonWithTitle(NSLocalizedString(YellrConstants.LocalPostDetail.ReportOkay, comment: "Local post detail Screen - okay"))
            alert.show()
            
        }
    }
    
    @IBAction func upVoteClicked(sender: UIButton) {

        //send to api
        post(["post_id":String(storyId), "is_up_vote":"1"], "register_vote", self.lat, self.long) { (succeeded: Bool, msg: String) -> () in
            Yellr.println(msg)
            //TODO: apply response results to button pressess
            //currently we are changing UI feedback assuming that
            //request will always succeed
        }
        
            
            if (hasVoted == "Yes") {
                
                if (isUpVote == "Yes") {
                    
                    //upvote being removed
                    upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                    downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                    
                    //remove vote
                    hasVoted = "No"
                    
                    //update vote count
                    var getCurrentUpvoteCount = upVoteCount?.text?.toInt()
                    upVoteCount?.text = String(getCurrentUpvoteCount! - 1)
                    
                } else {
                    
                    //changing down vote to up vote
                    upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.up_vote_green)
                    downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                    upVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.up_vote_green), forState: .Normal)
                    
                    //register the up vote
                    isUpVote = "Yes"
                    
                    // update up vote count
                    var getCurrentUpvoteCount = upVoteCount?.text?.toInt()
                    upVoteCount?.text = String(getCurrentUpvoteCount! + 1)
                    
                    // update down vote count
                    var getCurrentDownvoteCount = downVoteCount?.text?.toInt()
                    downVoteCount?.text = String(getCurrentDownvoteCount! - 1)
                    
                }
                
            } else {
                
                //first time voting
                upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.up_vote_green)
                downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                upVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.up_vote_green), forState: .Normal)
                
                hasVoted = "Yes"
                isUpVote = "Yes"
                
                //update vote count
                var getCurrentUpvoteCount = upVoteCount?.text?.toInt()
                upVoteCount?.text = String(getCurrentUpvoteCount! + 1)
                
            }
            
        
    }
    
    @IBAction func downVoteClicked(sender: UIButton) {

        //send to api
        post(["post_id":String(storyId), "is_up_vote":"0"], "register_vote", self.lat, self.long) { (succeeded: Bool, msg: String) -> () in
            Yellr.println(msg)
        }
            
            if (hasVoted == "Yes") {
                
                if (isUpVote == "Yes") {
                    
                    //downvote being removed
                    upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                    downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                    
                    //remove vote
                    hasVoted = "No"
                    
                    //update downvote count
                    var getCurrentDownvoteCount = downVoteCount?.text?.toInt()
                    upVoteCount?.text = String(getCurrentDownvoteCount! - 1)
                    
                } else {
                    
                    //changing up vote to down vote
                    upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                    downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.down_vote_red)
                    downVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.down_vote_red), forState: .Normal)
                    
                    //register the up vote
                    isUpVote = "No"
                    
                    // update up vote count
                    var getCurrentUpvoteCount = upVoteCount?.text?.toInt()
                    upVoteCount?.text = String(getCurrentUpvoteCount! - 1)
                    
                    // update down vote count
                    var getCurrentDownvoteCount = downVoteCount?.text?.toInt()
                    downVoteCount?.text = String(getCurrentDownvoteCount! + 1)
                    
                }
                
            } else {
                
                //first time down voting
                upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.down_vote_red)
                downVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.down_vote_red), forState: .Normal)
                hasVoted = "Yes"
                isUpVote = "No"
                
                //update down vote count
                var getCurrentDownvoteCount = downVoteCount?.text?.toInt()
                downVoteCount?.text = String(getCurrentDownvoteCount! - 1)
                
            }
            
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initVoteButtons(downVoteBtn, upVoteBtn)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)

    }
}