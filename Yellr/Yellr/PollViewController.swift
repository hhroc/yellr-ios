//
//  PollViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 8/9/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit

class PollViewController : UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var mediaContainer: UIScrollView!
    @IBOutlet weak var pollQuestionLabel: UILabel!
    
    var pollOptionsTrack = [Int:Bool]()
    var pollQuestion: String = ""
    var pollOptions = [String]()
    var pollId:Int = 0
    var pollOptionSelectedTag:Int = 0
    var latitude:String = ""
    var longitude:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mediaContainer.delegate = self;
        self.mediaContainer.scrollEnabled = true;
        self.mediaContainer.showsVerticalScrollIndicator = true
        self.mediaContainer.indicatorStyle = .Default
        self.setupPoll()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewDidLayoutSubviews() {
        self.mediaContainer.contentSize = CGSize(width:self.mediaContainer.frame.width, height: 600)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func submitTapped(sender: UIBarButtonItem) {
        Yellr.println(pollOptionSelectedTag - 100200)
        
        let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinningActivity.labelText = "Posting"
        spinningActivity.userInteractionEnabled = false
        
        if (pollOptionSelectedTag == 0) {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            self.processPollDone("Please choose an option first")
            
        } else {
        
            post(["media_type":"text", "media_file":"text", "media_text":String(pollOptionSelectedTag - 100200)], "upload_media", self.latitude, self.longitude) { (succeeded: Bool, msg: String) -> () in
                Yellr.println("Media Uploaded : " + msg)
                
                if (msg != "NOTHING" && msg != "Error") {
                    
                    post(["assignment_id":String(self.pollId), "media_objects":"[\""+msg+"\"]"], "publish_post", self.latitude, self.longitude) { (succeeded: Bool, msg: String) -> () in
                        Yellr.println("Post Added : " + msg)
                        if (msg != "NOTHING") {
                            
                            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                            //TODO: show success
                            self.processPollDone("Thanks!")
                            
                            //save used assignment ID / poll ID in UserPrefs to grey out used assignment item
                            let asdefaults = NSUserDefaults.standardUserDefaults()
                            var savedAssignmentIds = ""
                            if asdefaults.objectForKey(YellrConstants.Keys.RepliedToAssignments) == nil {
                                
                            } else {
                                savedAssignmentIds = asdefaults.stringForKey(YellrConstants.Keys.RepliedToAssignments)!
                            }
                            asdefaults.setObject(savedAssignmentIds + "[" + String(self.pollId) + "]", forKey: YellrConstants.Keys.RepliedToAssignments)
                            asdefaults.synchronize()
                            
                        } else {
                            //fail toast
                            Yellr.println("Poll + Text Upload failed")
                            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                            self.processPollDone("Failed! Please try again.")

                        }
                    }
                } else {
                    Yellr.println("Text Upload failed")
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    self.processPollDone("Failed! Please try again.")

                }
                
            }
            
        }
    }
    
    //MARK: poll setup functions
    func setupPoll() {
        var button: UIButton!
        var buttonPaddingTop: CGFloat
        var buttonWidth: CGFloat = UIScreen.mainScreen().bounds.size.width - 35.0
        Yellr.println(buttonWidth)
        
        self.pollQuestionLabel.text = self.pollQuestion
        self.pollQuestionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.pollQuestionLabel.numberOfLines = 0
        self.pollQuestionLabel.sizeToFit()
        
        var i = 0;
        for po in pollOptions {
            buttonPaddingTop = 50.0 * CGFloat(i)
            button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            button.setTitle(po, forState: UIControlState.Normal)
            button.frame = CGRectMake(0.0, buttonPaddingTop, buttonWidth, 40.0)
            button.addTarget(self, action: Selector("pollButtonTouched:"), forControlEvents: UIControlEvents.TouchUpInside)
            button.tag = 100200 + i
            pollOptionsTrack[button.tag] = false
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 1
            button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            button.backgroundColor = UIColorFromRGB(YellrConstants.Colors.very_light_yellow)
            button.layer.borderColor = UIColorFromRGB(YellrConstants.Colors.very_light_yellow).CGColor
            
            self.mediaContainer.addSubview(button)
            i++
            
            //CGRectMake
        }
    }
    
    func pollButtonTouched(sender: UIButton!) {
        for (tag,status) in pollOptionsTrack {
            var tmpButton = self.view.viewWithTag(tag) as? UIButton
            tmpButton!.backgroundColor = UIColorFromRGB(YellrConstants.Colors.very_light_yellow)
            tmpButton!.layer.borderColor = UIColorFromRGB(YellrConstants.Colors.very_light_yellow).CGColor
            pollOptionsTrack[tag] = false
        }
        pollOptionSelectedTag = sender.tag
        pollOptionsTrack[sender.tag] = true
        sender.backgroundColor = UIColorFromRGB(YellrConstants.Colors.dark_yellow)
        sender.layer.borderColor = UIColorFromRGB(YellrConstants.Colors.dark_yellow).CGColor
    }
        
    func processPollDone(mesg: String) {
        let spinningActivityFail = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        spinningActivityFail.customView = UIView()
        spinningActivityFail.mode = MBProgressHUDMode.CustomView
        spinningActivityFail.labelText = mesg
        //spinningActivityFail.yOffset = iOS8 ? 225 : 175
        spinningActivityFail.hide(true, afterDelay: NSTimeInterval(2.5))
    }
    
}