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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString(YellrConstants.AddPost.Title, comment: "Add Post Screen title")
        
        var buttonString = String.fontAwesomeString("fa-camera")
        var buttonStringAttributed = NSMutableAttributedString(string: buttonString, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 11.00)!])
        buttonStringAttributed.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize("FontAwesome", fontSize: 20), range: NSRange(location: 0,length: 1))
        
        photoBtn.titleLabel?.textAlignment = .Center
        photoBtn.titleLabel?.numberOfLines = 2
        photoBtn.setAttributedTitle(buttonStringAttributed, forState: .Normal)
        photoBtn.backgroundColor = UIColorFromRGB(YellrConstants.Colors.yellow)
        
        buttonString = String.fontAwesomeString("fa-video-camera")
        buttonStringAttributed = NSMutableAttributedString(string: buttonString, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 11.00)!])
        buttonStringAttributed.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize("FontAwesome", fontSize: 20), range: NSRange(location: 0,length: 1))
        
        vdoBtn.titleLabel?.textAlignment = .Center
        vdoBtn.titleLabel?.numberOfLines = 2
        vdoBtn.setAttributedTitle(buttonStringAttributed, forState: .Normal)
        vdoBtn.backgroundColor = UIColorFromRGB(YellrConstants.Colors.yellow)
        
        buttonString = String.fontAwesomeString("fa-microphone")
        buttonStringAttributed = NSMutableAttributedString(string: buttonString, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 11.00)!])
        buttonStringAttributed.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize("FontAwesome", fontSize: 20), range: NSRange(location: 0,length: 1))
        
        recordBtn.titleLabel?.textAlignment = .Center
        recordBtn.titleLabel?.numberOfLines = 2
        recordBtn.setAttributedTitle(buttonStringAttributed, forState: .Normal)
        recordBtn.backgroundColor = UIColorFromRGB(YellrConstants.Colors.yellow)
        
    }
    
    //dismiss the addpostmodal on pressing cancel
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
        println("dd")
    }
    
}
