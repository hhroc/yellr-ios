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
        
    }
    
    //dismiss the addpostmodal on pressing cancel
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
        println("dd")
    }
    
}
