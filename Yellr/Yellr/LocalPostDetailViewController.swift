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
        if(iOS8) {
            
            let alertController = UIAlertController(title: NSLocalizedString(YellrConstants.LocalPostDetail.ReportTitle, comment: "Local post detail Screen - alert title"), message:
                NSLocalizedString(YellrConstants.LocalPostDetail.ReportMessage, comment: "Local post detail Screen - alert message"), preferredStyle: UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString(YellrConstants.LocalPostDetail.ReportOkay, comment: "Local post detail Screen - okay"), style: UIAlertActionStyle.Default, handler: { (action) in
                //dismiss the add post view on pressing okay
                self.dismissViewControllerAnimated(true, completion: nil)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVoteButtons(downVoteBtn, upVoteBtn)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)

    }
}