//
//  AddPostViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 6/2/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreLocation
import MediaPlayer
import AVFoundation

class AddPostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var photoBtn: UIButton!
    @IBOutlet weak var vdoBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var submitBtn: UIBarButtonItem!
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    
    @IBOutlet weak var contentView: UIView!
    
    
    @IBOutlet weak var addPostTitle: UILabel!
    @IBOutlet weak var addPostDesc: UILabel!
    @IBOutlet weak var postContent: UITextField!
    
    var chosenMediaType = 3 //0 - pic, 1 - video, 2 - audio, 3 - text
    var postId: Int = 0
    var postTitle: String!
    var postDesc: String!
    var asgPost: String!
    var popover:UIPopoverController? = nil
    
    var latitude:String = ""
    var longitude:String = ""
    var pollOptionsTrack = [Int:Bool]()
    var videoPathString = ""
    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    var moviePlayer: MPMoviePlayerController?
    
    var (abRecord, abPlay, abStop) = (UIButton(), UIButton(), UIButton())
    var recordStatusLabel = UILabel()
    
    //Audio player, recorder
    var recorder: AVAudioRecorder!
    var player:AVAudioPlayer!
    var meterTimer:NSTimer!
    var soundFileURL:NSURL?
    var audioRecordView:UIView!
    //
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString(YellrConstants.AddPost.Title, comment: "Add Post Screen title")
        
        picker.delegate = self
        
        photoBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.black), forState: .Normal)
        photoBtn.setFontAwesome(fontAwesome: "f030", forState: .Normal)
        
        photoBtn.titleLabel?.textAlignment = .Center
        photoBtn.backgroundColor = UIColorFromRGB(YellrConstants.Colors.yellow)
        photoBtn.layer.cornerRadius = 20
        //photoBtn.frame.size.width += 20
        
        vdoBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.black), forState: .Normal)
        vdoBtn.setFontAwesome(fontAwesome: "f03d", forState: .Normal)
        
        vdoBtn.titleLabel?.textAlignment = .Center
        vdoBtn.backgroundColor = UIColorFromRGB(YellrConstants.Colors.yellow)
        //temp change for app store submission
        //vdoBtn.backgroundColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
        //vdoBtn.enabled = false
        vdoBtn.layer.cornerRadius = 20
        
        recordBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.black), forState: .Normal)
        recordBtn.setFontAwesome(fontAwesome: "f130", forState: .Normal)
        
        recordBtn.titleLabel?.textAlignment = .Center
        recordBtn.backgroundColor = UIColorFromRGB(YellrConstants.Colors.yellow)
        //temp change for app store submission
        //recordBtn.backgroundColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
        //recordBtn.enabled = false
        recordBtn.layer.cornerRadius = 20
        
        if (postTitle != nil) {
            addPostTitle.text = postTitle
            addPostTitle.lineBreakMode = NSLineBreakMode.ByWordWrapping
            addPostTitle.numberOfLines = 0
            addPostTitle.sizeToFit()
        }
        
        if (postDesc != nil) {
            addPostDesc.text = postDesc
            addPostDesc.lineBreakMode = NSLineBreakMode.ByWordWrapping
            addPostDesc.numberOfLines = 0
            addPostDesc.sizeToFit()
            
            //add clickable event desc
            addPostDesc.userInteractionEnabled = true
            //let tapGesture = UITapGestureRecognizer(target: self, action: "klikPlay:")
            addPostDesc.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "descTapped:"))
            //view.addGestureRecognizer(tapGesture)
        }
        
        postContent.delegate = self
        //self.setupPoll()
        
    }
    
    //on tapping desc label, open url if any
    func descTapped(sender:UITapGestureRecognizer){
        
        Yellr.println(postDesc)
        let res = "http?://([-\\w\\.]+)+(:\\d+)?(/([\\w/_\\.]*(\\?\\S+)?)?)?".getMatchesFine(postDesc)
        Yellr.println(res)
        
        if (res.count >= 1) {
            if let checkURL = NSURL(string: res[0]) {
                if UIApplication.sharedApplication().openURL(checkURL) {
                    //url successfully opened
                }
            } else {
                //invalid url
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        recorder = nil
        player = nil
        moviePlayer = nil
    }
    
    //for the location object
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        //this check is needed to add the additional
        //location methods for ios8
        if iOS8 {
            locationManager.requestWhenInUseAuthorization()
        } else {
            
        }
        
        locationManager.startUpdatingLocation()
        startLocation = nil
        
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        
        abRecord.setTitleColor(UIColor.blueColor(), forState: .Normal)
        abRecord.setTitle("Record", forState: .Normal)
        abRecord.frame = CGRectMake(0, 0, 100, 50)
        abRecord.tag = YellrConstants.TagIds.AddPostAudioButtonRecord
        abRecord.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        
        abPlay.setTitleColor(UIColor.blueColor(), forState: .Normal)
        abPlay.setTitle("Play", forState: .Normal)
        abPlay.frame = CGRectMake(115, 0, 100, 50)
        abPlay.tag = YellrConstants.TagIds.AddPostAudioButtonPlay
        abPlay.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        
        abStop.setTitleColor(UIColor.blueColor(), forState: .Normal)
        abStop.setTitle("Stop", forState: .Normal)
        abStop.frame = CGRectMake(230, 0, 100, 50)
        abStop.tag = YellrConstants.TagIds.AddPostAudioButtonStop
        abStop.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        
        recordStatusLabel.text = ""
        recordStatusLabel.font = UIFont(name: "MarkerFelt-Thin", size: 45)
        recordStatusLabel.textColor = UIColor.redColor()
        recordStatusLabel.textAlignment = .Center
        recordStatusLabel.numberOfLines = 2
        recordStatusLabel.frame = CGRectMake(0, 80, 300, 500)
        
        abPlay.enabled = false
        abStop.enabled = false
        setSessionPlayback()
        askForNotifications()
        
        self.chosenMediaType = 2
        
        self.audioRecordView = UIView(frame:CGRectMake(0, 0, 400, 300))
        self.audioRecordView.addSubview(abRecord)
        self.audioRecordView.addSubview(abStop)
        self.audioRecordView.addSubview(abPlay)
        self.audioRecordView.tag = YellrConstants.TagIds.AddPostAudioView
        //remove views
        self.removeViewsNotNeeded()
        self.contentView.addSubview(self.audioRecordView)
    }
    
    func pressed(sender: UIButton) {
        if (sender.tag == YellrConstants.TagIds.AddPostAudioButtonRecord) {
            
            //Record
            if player != nil && player.playing {
                player.stop()
            }
            
            if recorder == nil {
                Yellr.println("recording. recorder nil")
                abRecord.setTitle("Pause", forState:.Normal)
                abPlay.enabled = false
                abStop.enabled = true
                recordWithPermission(true)
                return
            }
            
            if recorder != nil && recorder.recording {
                Yellr.println("pausing")
                recorder.pause()
                abRecord.setTitle("Continue", forState:.Normal)
                
            } else {
                Yellr.println("recording")
                abRecord.setTitle("Pause", forState:.Normal)
                abPlay.enabled = false
                abStop.enabled = true
                //            recorder.record()
                recordWithPermission(false)
            }
            
        } else if (sender.tag == YellrConstants.TagIds.AddPostAudioButtonStop) {
            
            //Stop Button
            Yellr.println("stop")
            
            recorder?.stop()
            player?.stop()
            
            meterTimer.invalidate()
            
            abRecord.setTitle("Record", forState:.Normal)
            let session:AVAudioSession = AVAudioSession.sharedInstance()
            var error: NSError?
            if !session.setActive(false, error: &error) {
                println("could not make session inactive")
                if let e = error {
                    println(e.localizedDescription)
                    return
                }
            }
            abPlay.enabled = true
            abStop.enabled = false
            abRecord.enabled = true
            recorder = nil
            
        } else if (sender.tag == YellrConstants.TagIds.AddPostAudioButtonPlay) {
            
            //Play Button
            Yellr.println("playing")
            var error: NSError?
            
            if let r = recorder {
                self.player = AVAudioPlayer(contentsOfURL: r.url, error: &error)
                if self.player == nil {
                    if let e = error {
                        println(e.localizedDescription)
                    }
                }
            } else {
                self.player = AVAudioPlayer(contentsOfURL: soundFileURL!, error: &error)
                if player == nil {
                    if let e = error {
                        println(e.localizedDescription)
                    }
                }
            }
            
            abStop.enabled = true
            
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
            
        }
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
            self.chosenMediaType = 0
            if (videoCamera) {
                self.chosenMediaType = 1
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
                self.chosenMediaType = 1
                picker.mediaTypes = [kUTTypeMovie!]
            } else {
                self.chosenMediaType = 0
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
        
        var postFail : Bool = false
        var postCont = postContent.text

        if (postCont != "") {
            
            if (self.latitude == "" || self.longitude == "") {
                
                //show location empty hud
                let postAcFail = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                postAcFail.customView = UIView()
                postAcFail.mode = MBProgressHUDMode.CustomView
                postAcFail.labelText = NSLocalizedString(YellrConstants.AddPost.FailMsgLocation, comment: "Empty Location Fail")
                //postAcFail.yOffset = iOS8 ? 225 : 175
                postAcFail.hide(true, afterDelay: NSTimeInterval(2.5))
                
            } else {
            
                let spinningActivity = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                spinningActivity.labelText = "Posting"
                spinningActivity.userInteractionEnabled = false
                
                Yellr.println("ChosenMedia:" + String(self.chosenMediaType))
                
                if (self.chosenMediaType == 0) {
                    //image data type
                    
                    if let imagePick = self.contentView.viewWithTag(YellrConstants.TagIds.AddPostImageView) as? UIImageView {
                        
                        
                        let imageData:NSData = NSData(data: UIImageJPEGRepresentation(imagePick.image, 1.0))
                        
                        postImage(["media_type":"image", "media_caption":postCont], imageData, self.latitude, self.longitude){ (succeeded: Bool, msg: String) -> () in
                            Yellr.println("Image Uploaded : " + msg)
                            
                            if (msg != "NOTHING" && msg != "Error") {
                                
                                post(["assignment_id":String(self.postId), "media_objects":"[\""+msg+"\"]"], "publish_post", self.latitude, self.longitude) { (succeeded: Bool, msg: String) -> () in
                                    Yellr.println("Post Added : " + msg)
                                    if (msg != "NOTHING") {
                                        
                                        if (self.asgPost != nil) {
                                            self.processSuccesfulPostResults(YellrConstants.AddPost.checkVersionOnceAs)
                                        } else {
                                            self.processSuccesfulPostResults(YellrConstants.AddPost.checkVersionOnce)
                                        }
                                        
                                    } else {
                                        //fail toast
                                        Yellr.println("Image + Text Upload failed")
                                        postFail = true
                                        self.processPostFailed(postFail)
                                    }
                                }
                            } else {
                                Yellr.println("Image Text Upload failed")
                                postFail = true
                                self.processPostFailed(postFail)
                            }
                            
                        }
                        
                    }
                    
                } else if (self.chosenMediaType == 1) {
                    
                    //video data type
                    let videoData:NSData = NSData(contentsOfMappedFile: self.videoPathString)!
                    postImage(["media_type":"video", "media_caption":postCont], videoData, self.latitude, self.longitude){ (succeeded: Bool, msg: String) -> () in
                        Yellr.println("Video Uploaded : " + msg)
                        
                        if (msg != "NOTHING" && msg != "Error") {
                            
                            post(["assignment_id":String(self.postId), "media_objects":"[\""+msg+"\"]"], "publish_post", self.latitude, self.longitude) { (succeeded: Bool, msg: String) -> () in
                                Yellr.println("Post Added : " + msg)
                                if (msg != "NOTHING") {
                                    
                                    if (self.asgPost != nil) {
                                        self.processSuccesfulPostResults(YellrConstants.AddPost.checkVersionOnceAs)
                                    } else {
                                        self.processSuccesfulPostResults(YellrConstants.AddPost.checkVersionOnce)
                                    }
                                    
                                } else {
                                    //fail toast
                                    Yellr.println("Video + Text Upload failed")
                                    postFail = true
                                    self.processPostFailed(postFail)
                                }
                            }
                        } else {
                            Yellr.println("Video Upload failed")
                            postFail = true
                            self.processPostFailed(postFail)
                        }
                        
                    }
                    
                } else if (self.chosenMediaType == 2) {
                    
                    //audio data type
                    Yellr.println(soundFileURL)
                    let audioData:NSData = NSData(contentsOfURL: self.soundFileURL!)!
                    postImage(["media_type":"audio", "media_caption":postCont], audioData, self.latitude, self.longitude){ (succeeded: Bool, msg: String) -> () in
                        Yellr.println("Audio Uploaded : " + msg)
                        
                        if (msg != "NOTHING" && msg != "Error") {
                            
                            post(["assignment_id":String(self.postId), "media_objects":"[\""+msg+"\"]"], "publish_post", self.latitude, self.longitude) { (succeeded: Bool, msg: String) -> () in
                                Yellr.println("Post Added : " + msg)
                                if (msg != "NOTHING") {
                                    
                                    if (self.asgPost != nil) {
                                        self.processSuccesfulPostResults(YellrConstants.AddPost.checkVersionOnceAs)
                                    } else {
                                        self.processSuccesfulPostResults(YellrConstants.AddPost.checkVersionOnce)
                                    }
                                    
                                } else {
                                    //fail toast
                                    Yellr.println("Audio + Text Upload failed")
                                    postFail = true
                                    self.processPostFailed(postFail)
                                }
                            }
                        } else {
                            Yellr.println("Audio Upload failed")
                            postFail = true
                            self.processPostFailed(postFail)
                        }
                        
                    }
                    
                } else {
                    
                    post(["media_type":"text", "media_file":"text", "media_text":postCont], "upload_media", self.latitude, self.longitude) { (succeeded: Bool, msg: String) -> () in
                        Yellr.println("Media Uploaded : " + msg)
                        
                        if (msg != "NOTHING" && msg != "Error") {
                            
                            post(["assignment_id":String(self.postId), "media_objects":"[\""+msg+"\"]"], "publish_post", self.latitude, self.longitude) { (succeeded: Bool, msg: String) -> () in
                                Yellr.println("Post Added : " + msg)
                                if (msg != "NOTHING") {
                                    
                                    if (self.asgPost != nil) {
                                        self.processSuccesfulPostResults(YellrConstants.AddPost.checkVersionOnceAs)
                                    } else {
                                        self.processSuccesfulPostResults(YellrConstants.AddPost.checkVersionOnce)
                                    }
                                    
                                    //save used assignment ID in UserPrefs to grey out used assignment item
                                    if (self.postId != 0) {
                                        let asdefaults = NSUserDefaults.standardUserDefaults()
                                        var savedAssignmentIds = ""
                                        if asdefaults.objectForKey(YellrConstants.Keys.RepliedToAssignments) == nil {

                                        } else {
                                            savedAssignmentIds = asdefaults.stringForKey(YellrConstants.Keys.RepliedToAssignments)!
                                        }
                                        asdefaults.setObject(savedAssignmentIds + "[" + String(self.postId) + "]", forKey: YellrConstants.Keys.RepliedToAssignments)
                                        asdefaults.synchronize()
                                    }
                                    
                                } else {
                                    //fail toast
                                    Yellr.println("Text + Text Upload failed")
                                    postFail = true
                                    self.processPostFailed(postFail)
                                }
                            }
                        } else {
                            Yellr.println("Text Upload failed")
                            postFail = true
                            self.processPostFailed(postFail)
                        }
                        
                    }
                    
                }
            
            }
            
        } else {
            //show text empty hud
            let postAcFail = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            postAcFail.customView = UIView()
            postAcFail.mode = MBProgressHUDMode.CustomView
            postAcFail.labelText = NSLocalizedString(YellrConstants.AddPost.FailMsgEmptyPost, comment: "Empty Post Text Fail")
            //postAcFail.yOffset = iOS8 ? 225 : 175
            postAcFail.hide(true, afterDelay: NSTimeInterval(2.5))
        }
        

    }
    
    func processPostFailed(postFail : Bool) {
        Yellr.println("Post Failed block reached")
        if (postFail) {
            Yellr.println("Post Failed")
            dispatch_async(dispatch_get_main_queue()) {
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                let spinningActivityFail = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                spinningActivityFail.customView = UIView()
                spinningActivityFail.mode = MBProgressHUDMode.CustomView
                spinningActivityFail.labelText = NSLocalizedString(YellrConstants.AddPost.FailMsg, comment: "Add Post Fail")
                //spinningActivityFail.yOffset = iOS8 ? 225 : 175
                spinningActivityFail.hide(true, afterDelay: NSTimeInterval(2.5))
            }
        }
    }
    
    func processSuccesfulPostResults(versionStringKey : String) {
    
        let defaults = NSUserDefaults.standardUserDefaults()
    
        if let name = defaults.stringForKey(versionStringKey) {
        
            //Not a first time user, but might be an user
            //with an updated version of the app
            
            if (name == YellrConstants.AppInfo.version) {
            
                Yellr.println("NOT First Time Free Post")
                
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
     
        Yellr.println("First Time Free Post")
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
        Yellr.println(self.chosenMediaType)
        if (self.chosenMediaType == 0) {
            Yellr.println("Here")
            var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            var pickedImage : UIImageView = UIImageView()
            pickedImage.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
            pickedImage.contentMode = .ScaleAspectFit
            pickedImage.image = chosenImage
            pickedImage.tag = YellrConstants.TagIds.AddPostImageView //a random identifier
            self.removeViewsNotNeeded()
            self.contentView.addSubview(pickedImage)
        } else if (self.chosenMediaType == 1) {
            let tempImage = info[UIImagePickerControllerMediaURL] as! NSURL
            let pathString = tempImage.relativePath
            startPlayingVideo(tempImage)
            Yellr.println(pathString)
            Yellr.println(tempImage)
            self.videoPathString = pathString!
        }
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Location Delegate functions
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var latestLocation: AnyObject = locations[locations.count - 1]
        
        self.latitude = String(format: "%.2f", latestLocation.coordinate.latitude)
        self.longitude = String(format: "%.2f", latestLocation.coordinate.longitude)
        
        //store lat long in prefs
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(self.latitude, forKey: YellrConstants.Direction.Latitude)
        defaults.setObject(self.longitude, forKey: YellrConstants.Direction.Longitude)
        defaults.synchronize()
        
        locationManager.stopUpdatingLocation()
        
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        Yellr.println(error)
        let alert = UIAlertView()
        alert.title = NSLocalizedString(YellrConstants.Location.Title, comment: "Location Error Title")
        alert.message = NSLocalizedString(YellrConstants.Location.Message, comment: "Location Error Message")
        alert.addButtonWithTitle(NSLocalizedString(YellrConstants.Location.Okay, comment: "Okay"))
        alert.show()
    }
    
    //MARK: Keyboard Delegates
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        postContent.resignFirstResponder()
        return true
    }
    
    //MARK: Video playing routines - mostly taken from http://git.io/vtaLK
    func videoHasFinishedPlaying(notification: NSNotification){
        
        Yellr.println("Video finished playing")
        
        /* Find out what the reason was for the player to stop */
        let reason =
        notification.userInfo![MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]
            as! NSNumber?
        
        if let theReason = reason{
            
            let reasonValue = MPMovieFinishReason(rawValue: theReason.integerValue)
            
            switch reasonValue!{
            case .PlaybackEnded:
                /* The movie ended normally */
                Yellr.println("Playback Ended")
            case .PlaybackError:
                /* An error happened and the movie ended */
                Yellr.println("Error happened")
            case .UserExited:
                /* The user exited the player */
                Yellr.println("User exited")
            }
            
            Yellr.println("Finish Reason = \(theReason)")
            stopPlayingVideo()
        }
        
    }
    
    //Video related functions
    func stopPlayingVideo() {
        
        if let player = moviePlayer{
            NSNotificationCenter.defaultCenter().removeObserver(self)
            //player.stop()
            //player.view.removeFromSuperview()
        }
        
    }
    
    func startPlayingVideo(url : NSURL ){
        
        /* Now create a new movie player using the URL */
        moviePlayer = MPMoviePlayerController(contentURL: url)
        
        if let player = moviePlayer{
            
            /* Listen for the notification that the movie player sends us
            whenever it finishes playing */
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "videoHasFinishedPlaying:",
                name: MPMoviePlayerPlaybackDidFinishNotification,
                object: nil)
            
            Yellr.println("Successfully instantiated the movie player")
            
            //player.view.setTranslatesAutoresizingMaskIntoConstraints(true)
            player.scalingMode = .AspectFit
            player.prepareToPlay()
            //player.movieSourceType = MPMovieSourceType.Streaming
            player.contentURL = url
            player.controlStyle = MPMovieControlStyle.Embedded
            player.scalingMode = MPMovieScalingMode.AspectFill
            player.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.contentView.frame.size.width, height: self.contentView.frame.size.height))
            //player.setFullscreen(true, animated: false)
            //player.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
            //player.view.autoresizesSubviews = true
            player.view.tag = YellrConstants.TagIds.AddPostVideoView
            //remove views
            self.removeViewsNotNeeded()
            self.contentView.addSubview(player.view)
            //player.play()
            
        } else {
            Yellr.println("Failed to instantiate the movie player")
        }
        
    }
    
    func removeViewsNotNeeded() {
        if (self.contentView?.viewWithTag(YellrConstants.TagIds.AddPostAudioView) != nil) {
            //check and remove existing Audio view
            self.contentView?.viewWithTag(YellrConstants.TagIds.AddPostAudioView)?.removeFromSuperview()
        }
        if (self.contentView?.viewWithTag(YellrConstants.TagIds.AddPostVideoView) != nil) {
            //check and remove existing Audio view
            self.contentView?.viewWithTag(YellrConstants.TagIds.AddPostVideoView)?.removeFromSuperview()
        }
        if (self.contentView?.viewWithTag(YellrConstants.TagIds.AddPostImageView) != nil) {
            //check and remove existing Audio view
            self.contentView?.viewWithTag(YellrConstants.TagIds.AddPostImageView)?.removeFromSuperview()
        }
    }
    
    //Audio record functions
    func setupRecorder() {
        var format = NSDateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        var currentFileName = "recording-\(format.stringFromDate(NSDate())).m4a"
        println(currentFileName)
        
        var dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var docsDir: AnyObject = dirPaths[0]
        var soundFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
        soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let filemanager = NSFileManager.defaultManager()
        if filemanager.fileExistsAtPath(soundFilePath) {
            // probably won't happen. want to do something about it?
            Yellr.println("sound exists")
        }
        
        var recordSettings:[NSObject: AnyObject] = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        var error: NSError?
        recorder = AVAudioRecorder(URL: soundFileURL!, settings: recordSettings, error: &error)
        if let e = error {
            Yellr.println(e.localizedDescription)
        } else {
            recorder.delegate = self
            recorder.meteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        }
    }
    
    func updateAudioMeter(timer:NSTimer) {
        
        if recorder.recording {
            let min = Int(recorder.currentTime / 60)
            let sec = Int(recorder.currentTime % 60)
            let s = String(format: "%02d:%02d", min, sec)
            recordStatusLabel.text = s
            recorder.updateMeters()
            // if you want to draw some graphics...
            var apc0 = recorder.averagePowerForChannel(0)
            var peak0 = recorder.peakPowerForChannel(0)
        }
    }
    
    func recordWithPermission(setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    Yellr.println("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    self.meterTimer = NSTimer.scheduledTimerWithTimeInterval(0.1,
                        target:self,
                        selector:"updateAudioMeter:",
                        userInfo:nil,
                        repeats:true)
                } else {
                    Yellr.println("Permission to record not granted")
                }
            })
        } else {
            Yellr.println("requestRecordPermission unrecognized")
        }
    }
    
    func setSessionPlayback() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayback, error:&error) {
            println("could not set session category")
            if let e = error {
                Yellr.println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                Yellr.println(e.localizedDescription)
            }
        }
    }
    
    func setSessionPlayAndRecord() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayAndRecord, error:&error) {
            println("could not set session category")
            if let e = error {
                Yellr.println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                Yellr.println(e.localizedDescription)
            }
        }
    }
    
    func askForNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"background:",
            name:UIApplicationWillResignActiveNotification,
            object:nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:"foreground:",
            name:UIApplicationWillEnterForegroundNotification,
            object:nil)
    }
    
    func background(notification:NSNotification) {
        Yellr.println("background")
    }
    
    func foreground(notification:NSNotification) {
        Yellr.println("foreground")
    }
}

// MARK: AVAudioRecorderDelegate
extension AddPostViewController : AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!,
        successfully flag: Bool) {
            println("finished recording \(flag)")
            abStop.enabled = false
            abPlay.enabled = true
            abRecord.setTitle("Record", forState:.Normal)
            
            // iOS8 and later
            var alert = UIAlertController(title: "Recorder",
                message: "Finished Recording",
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Keep", style: .Default, handler: {action in
                println("keep was tapped")
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: {action in
                println("delete was tapped")
                self.recorder.deleteRecording()
            }))
            self.presentViewController(alert, animated:true, completion:nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!,
        error: NSError!) {
            println("\(error.localizedDescription)")
    }
    
}

// MARK: AVAudioPlayerDelegate
extension AddPostViewController : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        Yellr.println("finished playing \(flag)")
        abRecord.enabled = true
        abStop.enabled = false
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        Yellr.println("\(error.localizedDescription)")
    }
}