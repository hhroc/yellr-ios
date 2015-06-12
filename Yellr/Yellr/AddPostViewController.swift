//
//  AddPostViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 6/2/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit

class AddPostViewController: UIViewController {
    
    @IBOutlet weak var photoBtn: UIButton!
    @IBOutlet weak var vdoBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var submitBtn: UIBarButtonItem!
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    
    @IBOutlet weak var addPostTitle: UILabel!
    @IBOutlet weak var addPostDesc: UILabel!
    @IBOutlet weak var postContent: UITextField!
    
    @IBOutlet weak var postingIndicator: UIActivityIndicatorView!
    
    var postTitle: String!
    var postDesc: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString(YellrConstants.AddPost.Title, comment: "Add Post Screen title")
        
        photoBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.black), forState: .Normal)
        photoBtn.setFontAwesome(fontAwesome: "f030", forState: .Normal)
        
        photoBtn.titleLabel?.textAlignment = .Center
        photoBtn.backgroundColor = UIColorFromRGB(YellrConstants.Colors.yellow)
        
        vdoBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.black), forState: .Normal)
        vdoBtn.setFontAwesome(fontAwesome: "f03d", forState: .Normal)
        
        vdoBtn.titleLabel?.textAlignment = .Center
        vdoBtn.backgroundColor = UIColorFromRGB(YellrConstants.Colors.yellow)
        
        recordBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.black), forState: .Normal)
        recordBtn.setFontAwesome(fontAwesome: "f130", forState: .Normal)
        
        recordBtn.titleLabel?.textAlignment = .Center
        recordBtn.backgroundColor = UIColorFromRGB(YellrConstants.Colors.yellow)
        
        if (postTitle != nil) {
            addPostTitle.text = postTitle
        }
        
        if (postDesc != nil) {
            addPostDesc.text = postDesc
        }
        
    }
    
    
    @IBAction func submitPost(sender: UIBarButtonItem) {
        
        let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinningActivity.labelText = "Posting"
        spinningActivity.userInteractionEnabled = false
        
        var postFail : Bool = false
        var postCont = postContent.text

        post(["media_type":"text", "media_file":"text", "media_text":postCont], "upload_media") { (succeeded: Bool, msg: String) -> () in
            println("Media Uploaded : " + msg)
            if (msg != "NOTHING" && msg != "Error") {
                post(["assignment_id":"0", "media_objects":"[\""+msg+"\"]"], "publish_post") { (succeeded: Bool, msg: String) -> () in
                    println("Post Added : " + msg)
                    if (msg != "NOTHING") {

                        self.dismissViewControllerAnimated(true, completion: nil);
                        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                        postFail = true
                        //show done hud on the source view controller
                        dispatch_async(dispatch_get_main_queue()) {
                            let spinningActivityDone = MBProgressHUD.showHUDAddedTo(self.presentingViewController?.view, animated: true)
                            let checkImage = UIImage(named: "37x-Checkmark.png")
                            spinningActivityDone.customView = UIImageView(image: checkImage)
                            spinningActivityDone.mode = MBProgressHUDMode.CustomView
                            spinningActivityDone.labelText = NSLocalizedString(YellrConstants.AddPost.SuccessMsg, comment: "Add Post Success")
                            spinningActivityDone.hide(true, afterDelay: NSTimeInterval(3))
                        }
                        
                    } else {
                        //fail toast
                        postFail = true
                    }
                }
            } else {
                postFail = true
            }
            if (postFail) {
                dispatch_async(dispatch_get_main_queue()) {
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    let spinningActivityFail = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    spinningActivityFail.customView = UIView()
                    spinningActivityFail.mode = MBProgressHUDMode.CustomView
                    spinningActivityFail.labelText = NSLocalizedString(YellrConstants.AddPost.FailMsg, comment: "Add Post Fail")
                    spinningActivityFail.yOffset = iOS8 ? 225 : 175
                    spinningActivityFail.hide(true, afterDelay: NSTimeInterval(2.5))
                }
            }
        }
    }
    
    //dismiss the addpostmodal on pressing cancel
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
        //println("dd")
    }
    
}
