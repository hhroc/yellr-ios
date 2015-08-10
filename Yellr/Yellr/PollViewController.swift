//
//  PollViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 8/9/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit

class PollViewController : UIViewController {
    
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var pollQuestionLabel: UILabel!
    
    var pollOptionsTrack = [Int:Bool]()
    var pollQuestion: String = ""
    var pollOptions = [String]()
    var pollID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPoll()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancelTapped(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func submitTapped(sender: UIBarButtonItem) {
    }
    
    //MARK: poll setup functions
    func setupPoll() {
        var button: UIButton!
        var buttonPaddingTop: CGFloat
        var buttonWidth: CGFloat = UIScreen.mainScreen().bounds.size.width - 35.0
        Yellr.println(buttonWidth)
        
        self.pollQuestionLabel.text = self.pollQuestion
        
        for i in 0...3 {
            buttonPaddingTop = 50.0 * CGFloat(i)
            button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            button.setTitle("Option " + String(i) + " - Test Text and", forState: UIControlState.Normal)
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
        pollOptionsTrack[sender.tag] = true
        sender.backgroundColor = UIColorFromRGB(YellrConstants.Colors.dark_yellow)
        sender.layer.borderColor = UIColorFromRGB(YellrConstants.Colors.dark_yellow).CGColor
    }
    
}