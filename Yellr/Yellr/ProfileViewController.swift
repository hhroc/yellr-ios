//
//  ProfileViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 6/15/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var resetCuidButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cuidValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString(YellrConstants.Profile.Title, comment: "Profile Screen title")
        self.cancelButton.title =  NSLocalizedString(YellrConstants.Common.BackButton, comment: "Profile Screen back button")
        self.resetCuidButton.title = NSLocalizedString(YellrConstants.Profile.ResetCUIDButton, comment: "Profile Screen Reset CUID button")
        
        self.cuidValue.text = "CUID: " + getCUID()
    }
    
    //dismiss the profilemodal on pressing cancel
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }

    @IBAction func resetCUIDPressed(sender: UIBarButtonItem) {
    }
}