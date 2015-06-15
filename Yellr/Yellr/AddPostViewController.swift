//
//  AddPostViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 6/2/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit
import MobileCoreServices

class AddPostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate {
    
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
        
        //pickedImage.image = UIImage(named: "Debjit.jpg")
        
    }
    
    @IBAction func takeVideo(sender: UIButton) {
        
        if (iOS8) {
            var alert:UIAlertController=UIAlertController(title: NSLocalizedString(YellrConstants.AddPost.PopMenuTitleVideo, comment: "Choose Video Menu"), message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            var cameraAction = UIAlertAction(title: NSLocalizedString(YellrConstants.AddPost.PopMenuCamera, comment: "Choose Camera"), style: UIAlertActionStyle.Default) {
                UIAlertAction in
                self.openCamera(true)
                
            }
            var galleryAction = UIAlertAction(title: NSLocalizedString(YellrConstants.AddPost.PopMenuGallery, comment: "Choose Gallery"), style: UIAlertActionStyle.Default) {
                UIAlertAction in
                self.openGallery(true)
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
        } else {
            
            //for iOS7
//            let videoActionSheet = UIActionSheet()
//            videoActionSheet.addButtonWithTitle(YellrConstants.AddPost.PopMenuCamera)
//            videoActionSheet.addButtonWithTitle(YellrConstants.AddPost.PopMenuGallery)
//            videoActionSheet.cancelButtonIndex = 2
//            videoActionSheet.tag = 0
//            videoActionSheet.delegate = self
//            videoActionSheet.showInView(self.view)
            
            //UIActionSheet is giving weird view errors, using alert view for now
            
            let alert = UIAlertView()
            alert.delegate = self
            alert.tag = 2
            alert.title = NSLocalizedString(YellrConstants.AddPost.PopMenuTitleVideo, comment: "Choose Video Menu")
            alert.addButtonWithTitle(NSLocalizedString(YellrConstants.AddPost.PopMenuCamera, comment: "Camera"))
            alert.addButtonWithTitle(NSLocalizedString(YellrConstants.AddPost.PopMenuGallery, comment: "Gallery"))
            alert.addButtonWithTitle(NSLocalizedString(YellrConstants.AddPost.PopMenuCancel, comment: "Cancel"))
            alert.cancelButtonIndex = 2
            alert.show()
            
        }
        
    }
    
    @IBAction func takePhoto(sender: UIButton) {
        
        if (iOS8) {
        
            var alert:UIAlertController=UIAlertController(title: NSLocalizedString(YellrConstants.AddPost.PopMenuTitle, comment: "Choose Image Menu"), message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            var cameraAction = UIAlertAction(title: NSLocalizedString(YellrConstants.AddPost.PopMenuCamera, comment: "Choose Camera"), style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    self.openCamera(false)
                    
            }
            var galleryAction = UIAlertAction(title: NSLocalizedString(YellrConstants.AddPost.PopMenuGallery, comment: "Choose Gallery"), style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    self.openGallery(false)
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
            
        } else {
            
            //for ios7
//            let photoActionSheet = UIActionSheet()
//            photoActionSheet.addButtonWithTitle(YellrConstants.AddPost.PopMenuCamera)
//            photoActionSheet.addButtonWithTitle(YellrConstants.AddPost.PopMenuGallery)
//            photoActionSheet.cancelButtonIndex = 2
//            photoActionSheet.tag = 1
//            photoActionSheet.delegate = self
//            photoActionSheet.showInView(self.view)
//            //photoActionSheet.showFromTabBar(self.tabBarController!.tabBar)
            
            //UIActionSheet is giving weird view errors, using alert view for now
            
            let alert = UIAlertView()
            alert.delegate = self
            alert.tag = 1
            alert.title = NSLocalizedString(YellrConstants.AddPost.PopMenuTitle, comment: "Choose Image Menu")
            alert.addButtonWithTitle(NSLocalizedString(YellrConstants.AddPost.PopMenuCamera, comment: "Camera"))
            alert.addButtonWithTitle(NSLocalizedString(YellrConstants.AddPost.PopMenuGallery, comment: "Gallery"))
            alert.addButtonWithTitle(NSLocalizedString(YellrConstants.AddPost.PopMenuCancel, comment: "Cancel"))
            alert.cancelButtonIndex = 2
            alert.show()
            
        }

    }
    
    //videoCamera - whether or not to open the photo cam or video cam
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
            openGallery(videoCamera)
        }
    }
    
    //whether or not to show the videosor photos
    func openGallery(videoCamera : Bool) {
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            //what to show in gallery - photo or video
            if (videoCamera) {
                picker.mediaTypes = [kUTTypeMovie!]
            } else {
                picker.mediaTypes = [kUTTypeImage!]
            }
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
                        
                        if (self.asgPost != nil) {
                            self.processSuccesfulPostResults(YellrConstants.AddPost.checkVersionOnceAs)
                        } else {
                            self.processSuccesfulPostResults(YellrConstants.AddPost.checkVersionOnce)
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
    
    func processSuccesfulPostResults(versionStringKey : String) {
    
        let defaults = NSUserDefaults.standardUserDefaults()
    
        if let name = defaults.stringForKey(versionStringKey) {
        
            //Not a first time user, but might be an user
            //with an updated version of the app
            
            if (name == YellrConstants.AppInfo.version) {
            
                println("NOT First Time Free Post")
                
                //do not show first time popup
                //certain post completion tasks
                self.completionAddPostSuccess()
            
            } else {
            
                //show first time popup - user may have updated the app
                
                //call the completion tasks
                self.completionAddPostSuccessForFirstTimeUser()
                //populate this NSDefault name
                defaults.setObject(YellrConstants.AppInfo.version, forKey: versionStringKey)
            
            }
        
        } else {
        
            //first time user of the app
            
            //call the completion tasks
            self.completionAddPostSuccessForFirstTimeUser()
            //populate this NSDefault name
            defaults.setObject(YellrConstants.AppInfo.version, forKey: versionStringKey)
        
        }
    }

    //this function should be called when a post is succesful
    //for a new user or an user with an updated app
    func completionAddPostSuccessForFirstTimeUser() {
     
        println("First Time Free Post")
        //first time free post  - show one time popup
        dispatch_async(dispatch_get_main_queue()) {
            
            //hide the active HUDs
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            if(iOS8) {
                
                let alertController = UIAlertController(title: NSLocalizedString(YellrConstants.AddPost.FirstTimeTitle, comment: "Add Post Screen - Succesfully Posted"), message:
                    NSLocalizedString(YellrConstants.AddPost.FirstTimeMessage, comment: "Add Post Screen Message Succesful"), preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString(YellrConstants.AddPost.FirstTimeOkay, comment: "Okay"), style: UIAlertActionStyle.Default, handler: { (action) in
                    //dismiss the add post view on pressing okay
                    self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    ))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            } else {
                
                let alert = UIAlertView()
                alert.tag = 0
                alert.delegate = self
                alert.title = NSLocalizedString(YellrConstants.AddPost.FirstTimeTitle, comment: "Add Post Screen - Succesfully Posted")
                alert.message = NSLocalizedString(YellrConstants.AddPost.FirstTimeMessage, comment: "Add Post Screen Message Succesful")
                alert.addButtonWithTitle(NSLocalizedString(YellrConstants.AddPost.FirstTimeOkay, comment: "Okay"))
                alert.show()
                
            }
            
        }
        
    }
    
    //this function should be called when a post is succesful
    func completionAddPostSuccess() {
        self.dismissViewControllerAnimated(true, completion: nil);
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
        //show done hud on the source view controller
        dispatch_async(dispatch_get_main_queue()) {
            let spinningActivityDone = MBProgressHUD.showHUDAddedTo(self.presentingViewController?.view, animated: true)
            let checkImage = UIImage(named: "37x-Checkmark.png")
            spinningActivityDone.customView = UIImageView(image: checkImage)
            spinningActivityDone.mode = MBProgressHUDMode.CustomView
            spinningActivityDone.labelText = NSLocalizedString(YellrConstants.AddPost.SuccessMsg, comment: "Add Post Success")
            spinningActivityDone.hide(true, afterDelay: NSTimeInterval(3))
        }
    }
    
    //dismiss the addpostmodal on pressing cancel
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    //MARK: ActionSheet Delegates for iOS7
    func actionSheet(myActionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){

        if (myActionSheet.tag == 0) {
            
            //for video
            switch buttonIndex{
                
                case 0:
                    self.openCamera(true)
                    break;
                case 1:
                    self.openGallery(true)
                    break;
                default:
                    break;
                
            }
            
        } else if (myActionSheet.tag == 1) {
            
            //for photo
            switch buttonIndex{
                
                case 0:
                    self.openCamera(false)
                    break;
                case 1:
                    self.openGallery(false)
                    break;
                default:
                    break;
                
            }
            
        }
        
    }
    
    //MARK: Alert View Delegates for iOS7
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        if (View.tag == 0) {
            
            //first time post notify
            switch buttonIndex{
                
                case 0:
                    //dismiss the add post view on pressing okay
                    self.dismissViewControllerAnimated(true, completion: nil)
                    break;
                default:
                    break;
                
            }
            
        } else if (View.tag == 1) {
            
            //photo select cam / gallery
            switch buttonIndex{
                
                case 0:
                    self.openCamera(false)
                    break;
                case 1:
                    self.openGallery(false)
                    break;
                default:
                    break;
                
            }
            
        } else if (View.tag == 2) {
            
            //video select cam / gallery
            switch buttonIndex{
                
                case 0:
                    self.openCamera(true)
                    break;
                case 1:
                    self.openGallery(true)
                    break;
                default:
                    break;
                
            }
            
        }
        
    }
    
    //MARK: Delegates
    //on chosing image - do what
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        pickedImage.contentMode = .ScaleAspectFit
        pickedImage.image = chosenImage
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
