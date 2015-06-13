//
//  AddPostViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 6/2/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit
import MobileCoreServices

class AddPostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var photoBtn: UIButton!
    @IBOutlet weak var vdoBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var submitBtn: UIBarButtonItem!
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    
    @IBOutlet weak var pickedImage: UIImageView!
    
    @IBOutlet weak var addPostTitle: UILabel!
    @IBOutlet weak var addPostDesc: UILabel!
    @IBOutlet weak var postContent: UITextField!
    
    @IBOutlet weak var postingIndicator: UIActivityIndicatorView!
    
    var postTitle: String!
    var postDesc: String!
    var asgPost: String!
    var popover:UIPopoverController? = nil
    
    let picker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString(YellrConstants.AddPost.Title, comment: "Add Post Screen title")
        
        picker.delegate = self
        
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
    
    @IBAction func takeVideo(sender: UIButton) {
        
        
        var alert:UIAlertController=UIAlertController(title: NSLocalizedString(YellrConstants.AddPost.PopMenuTitle, comment: "Choose Image Menu"), message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: NSLocalizedString(YellrConstants.AddPost.PopMenuCamera, comment: "Choose Camera"), style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.openCamera(true)
            
        }
        var galleryAction = UIAlertAction(title: NSLocalizedString(YellrConstants.AddPost.PopMenuGallery, comment: "Choose Gallery"), style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.openGallery()
        }
        var cancelAction = UIAlertAction(title: NSLocalizedString(YellrConstants.AddPost.PopMenuCancel, comment: "Cancel"), style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            
        }
        
        // Add options
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        // Present the actionsheet - bottom pop menu
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            //for iPad - when we support in the future
            popover=UIPopoverController(contentViewController: alert)
            popover!.presentPopoverFromRect(photoBtn.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
        
    }
    
    @IBAction func takePhoto(sender: UIButton) {
        
        var alert:UIAlertController=UIAlertController(title: NSLocalizedString(YellrConstants.AddPost.PopMenuTitle, comment: "Choose Image Menu"), message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: NSLocalizedString(YellrConstants.AddPost.PopMenuCamera, comment: "Choose Camera"), style: UIAlertActionStyle.Default) {
                UIAlertAction in
                self.openCamera(false)
                
        }
        var galleryAction = UIAlertAction(title: NSLocalizedString(YellrConstants.AddPost.PopMenuGallery, comment: "Choose Gallery"), style: UIAlertActionStyle.Default) {
                UIAlertAction in
                self.openGallery()
        }
        var cancelAction = UIAlertAction(title: NSLocalizedString(YellrConstants.AddPost.PopMenuCancel, comment: "Cancel"), style: UIAlertActionStyle.Cancel) {
                UIAlertAction in
                
        }
        
        // Add options
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        // Present the actionsheet - bottom pop menu
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            //for iPad - when we support in the future
            popover=UIPopoverController(contentViewController: alert)
            popover!.presentPopoverFromRect(photoBtn.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }

    }
    
    func openCamera(videoCamera : Bool) {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.allowsEditing = false
            if (videoCamera) {
                picker.mediaTypes = [kUTTypeMovie!]
                picker.videoQuality = UIImagePickerControllerQualityType.TypeLow
            }
            picker.showsCameraControls = true
            self.presentViewController(picker, animated: true, completion: nil)
        } else {
            //show gallery if camera is not available
            openGallery()
        }
    }
    
    func openGallery() {
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(picker, animated: true, completion: nil)
        } else {
            //for iPad
            popover=UIPopoverController(contentViewController: picker)
            popover!.presentPopoverFromRect(photoBtn.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
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
                        
                        let defaults = NSUserDefaults.standardUserDefaults()
                        if (self.asgPost != nil) {
                            if let name = defaults.stringForKey(YellrConstants.AddPost.checkVersionOnceAs) {
                                
                            } else {
                                //first time assignment post
                                //populate this NSDefault name
                            }
                        } else {
                            if let name = defaults.stringForKey(YellrConstants.AddPost.checkVersionOnce) {
                                
                            } else {
                                //first time free post                                
                                //populate this NSDefault name
                            }
                        }
                        
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
    }
    
    //MARK: Delegates
    //on chosing image - do what
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        //pickedImage.contentMode = .ScaleAspectFit
        pickedImage.image = chosenImage
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
