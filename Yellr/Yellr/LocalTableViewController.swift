//
//  LocalTableViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 5/29/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit
import CoreLocation
import MediaPlayer

class LocalTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    let localViewModel = LocalViewModel()
    let backgroundQueue : dispatch_queue_t = dispatch_queue_create("yellr.net.yellr-ios.backgroundQueue", nil)
    let imageCache : NSCache = NSCache()
    
    var localPostsUrlEndpoint: String = ""
    var dataSource : Array<LocalPostDataModel> = []
    var webActivityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    var urlSession = NSURLSession.sharedSession()
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    var postListString = ""
    
    var lat: String = ""
    var long: String = ""
    
    var containerWidth: CGFloat = 0.0
    var moviePlayer:MPMoviePlayerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString(YellrConstants.LocalPosts.Title, comment: "Local Post Screen title")
        self.initWebActivityIndicator()
        
        //right side bar button items
        let profileBarButtonItem:UIBarButtonItem = UIBarButtonItem(fontAwesome: "f007", target: self, action: "profileTapped:")
        let fixedSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        fixedSpace.width = 30.0
        let addPostBarButtonItem:UIBarButtonItem = UIBarButtonItem(fontAwesome: "f044", target: self, action: "addPostTapped:")
        self.navigationItem.setRightBarButtonItems([addPostBarButtonItem, fixedSpace, profileBarButtonItem], animated: true)
        
        //left barbutton item
        let yellrBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: YellrConstants.AppInfo.Name, style: UIBarButtonItemStyle.Plain, target: self, action: "yellrTapped:")
        self.navigationItem.setLeftBarButtonItems([yellrBarButtonItem], animated: true)
        
        //show message to first time user
        self.messageForFirstTimer()

    }
    
    //for the yellow underline bars on selected tabs
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let subViews = self.tabBarController!.tabBar.subviews
        for subview in subViews{
            if (subview.tag == YellrConstants.TagIds.BottomTabLocal) {
                (subview as? UIView)!.hidden = false
            } else if (subview.tag == YellrConstants.TagIds.BottomTabAssignments) {
                (subview as? UIView)!.hidden = true
            } else if (subview.tag == YellrConstants.TagIds.BottomTabStories) {
                (subview as? UIView)!.hidden = true
            }
        }
        
        //location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        //this check is needed to add the additional
        //location methods for ios8
        if #available(iOS 8.0, *) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            
        }

        locationManager.startUpdatingLocation()
        startLocation = nil
        
    }
    
    //We need sections in order to load the
    //newly fetched data in the table view 
    //(data that is fetched on pulldown or new refresh)
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return localViewModel.numberOfSections()
    }
    
    //Determine the number of rows to show
    //in the tableview
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return localViewModel.numberOfRowsInSection(section)
        return self.dataSource.count
    }
    
    //Update the cell object to show labels/ buttons/ content
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocalTVCIdentifier", forIndexPath: indexPath) as! LocalTableViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
//    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 200.0;
//    }
//    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        //TODO: Implement Cache
        
        let localPostItem : LocalPostDataModel = self.dataSource[indexPath.row]
        var height:CGFloat = 120.0
        let calculationView : UITextView = UITextView()
        
        if let text = localPostItem.lp_media_text as? String {
            if (text.characters.count == 0) {
                //this is an image so check for caption
                
                if let mediaCaption = localPostItem.lp_media_caption as? String {
                    if (mediaCaption.characters.count == 0) {
                        //there is no caption
                        height += 140.0
                    } else {
                        //there is a caption
                        let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(18.0)]
                        calculationView.attributedText = NSAttributedString(string: mediaCaption, attributes: attrs)
                        let size : CGSize = calculationView.sizeThatFits(CGSizeMake(UIScreen.mainScreen().bounds.size.width - 75.0, 3.40282347E+38))
                        
                        height += size.height
                        
                        height += 140.0
                    }
                }
            } else {

                let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(18.0)]
                calculationView.attributedText = NSAttributedString(string: text, attributes: attrs)
                calculationView.sizeToFit()
                let size : CGSize = calculationView.sizeThatFits(CGSizeMake(UIScreen.mainScreen().bounds.size.width - 75.0, 3.40282347E+38))
                height += size.height
            }
            
        }
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Yellr.println("Here")
        self.performSegueWithIdentifier("LocalPostDetailSegue", sender: self)
    }
    
    //when profile button is tapped in UINavBar
    func profileTapped(sender:UIButton) {
        self.performSegueWithIdentifier("LocalToProfile", sender: self)
    }
    
    //when add post button is tapped in UINavBar
    func addPostTapped(sender:UIButton) {
        self.performSegueWithIdentifier("LocalToPost", sender: self)
    }
    
    //when Yellr button is tapped 
    func yellrTapped(sender:UIButton) {
        self.tabBarController?.selectedIndex = 0
    }
    
    //starts the tableviewload process
    //api call and then populate
    func loadLocalPostsTableView(latitude : String, longitude : String) {
        
        self.localPostsUrlEndpoint = buildUrl("get_local_posts.json", latitude: latitude, longitude: longitude)
        self.requestLocalPosts(self.localPostsUrlEndpoint, responseHandler: { (error, items) -> () in
            
            self.dataSource = items!
            
            dispatch_async(dispatch_get_main_queue()!, { () -> Void in
                self.tableView.reloadData()
                self.webActivityIndicator.hidden = true
            })
            
            
            
            let preferences = NSUserDefaults.standardUserDefaults()
            let postListKey = YellrConstants.Keys.PostListKeyName
            if preferences.objectForKey(postListKey) == nil {
                self.postListString = NSUUID().UUIDString.lowercaseString
                preferences.setValue(self.postListString, forKey: postListKey)
                //  Save to disk
                let didSave = preferences.synchronize()
                if !didSave {}
            } else {
                self.postListString = preferences.stringForKey(postListKey)!.lowercaseString
            }
        })
    }
    
    func configureCell(cell:LocalTableViewCell, atIndexPath indexPath:NSIndexPath) {
        
        let localPostItem : LocalPostDataModel = self.dataSource[indexPath.row]
        
        //remove media container image view
        for view in cell.mediaContainer.subviews{
            view.removeFromSuperview()
        }
        
        //set the button tags for upvote and downvote buttons
        cell.upVoteBtn.tag = indexPath.row
        cell.downVoteBtn.tag = indexPath.row
        
        cell.upVoteBtn.addTarget(self, action: "upVoteClicked:", forControlEvents: .TouchUpInside)
        cell.downVoteBtn.addTarget(self, action: "downVoteClicked:", forControlEvents: .TouchUpInside)
        
        //for the questionmark
        let attrs = [NSFontAttributeName : UIFont.fontAwesome(size: 13)]
        var qmString = NSMutableAttributedString(string:"\(String.fontAwesome(unicode: 0xf059)) ", attributes:attrs)
        
        if let postTitle = localPostItem.lp_question_text as? String {

            cell.postTitle?.text = "\(String.fontAwesome(unicode: 0xf059)) " + postTitle
            cell.postTitle?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.postTitle?.numberOfLines = 0
            cell.postTitle?.sizeToFit()
            
        } else {
            cell.postTitle?.text = ""
        }
        
        if let author = localPostItem.lp_first_name as? String {
            cell.postedBy?.text = author
        } else {
            cell.postedBy?.font = UIFont.fontAwesome(size: 13)
            cell.postedBy?.text = "\(String.fontAwesome(unicode: 0xf007)) " + NSLocalizedString(YellrConstants.LocalPosts.AnonymousUser, comment: "Anonymous User")
        }
        
        let postedOn:String = (localPostItem.lp_post_datetime as? String)!
        cell.postedOn?.font = UIFont.fontAwesome(size: 13)
        cell.postedOn?.text = "\(String.fontAwesome(unicode: 0xf040)) " + postedOn
        
        cell.upVoteCount?.text = NSString(format:"%d", (stringInterpolationSegment: (localPostItem.lp_up_vote_count as? Int)!)) as String
        //add - (negative to downvote counts)
        let downVoteCount = (localPostItem.lp_down_vote_count as? Int)!
        var downVoteCountString = NSString(format:"%d", (stringInterpolationSegment: downVoteCount)) as String
        if (downVoteCount != 0) {
            downVoteCountString = "-" + downVoteCountString
        }
        cell.downVoteCount?.text = downVoteCountString
        
        //set vote count colors based on whether or not user has voted
        if let hasVoted = localPostItem.lp_has_voted as? Bool {
            if (hasVoted) {
                let isUpVote : Bool = (localPostItem.lp_is_up_vote as? Bool)!
                if (isUpVote) {
                    cell.upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.up_vote_green)
                   cell.upVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.up_vote_green), forState: .Normal)
                    cell.downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                } else {
                    cell.upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                    cell.downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.down_vote_red)
                    cell.downVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.down_vote_red), forState: .Normal)
                }
            } else {
                cell.upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                cell.downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
            }
        } else {
            
        }
        
        if let postType = localPostItem.lp_media_type_name as? String {
            if (postType == "text") {
                
                let textView = UITextView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width - 75.0, cell.mediaContainer.frame.height))
                textView.text = localPostItem.lp_media_text as? String
                textView.font = UIFont(name: "ArialMT", size: 17.0)
                textView.hidden = false
                textView.sizeToFit()
                textView.scrollEnabled = false
                textView.editable = false
                textView.selectable = false
                textView.textAlignment = NSTextAlignment.Left
                cell.mediaContainer.addSubview(textView)
                cell.mediaContainer.hidden = false
                cell.setNeedsLayout()
                
            }
            
            if (postType == "image" || postType == "audio" || postType == "video") {
                
                cell.mediaContainer.hidden = false
                
                let textView = UITextView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width - 75.0, cell.mediaContainer.frame.height))
                textView.text = localPostItem.lp_media_caption as? String
                textView.font = UIFont(name: "ArialMT", size: 17.0)
                textView.hidden = false
                textView.sizeToFit()
                textView.scrollEnabled = false
                textView.editable = false
                textView.selectable = false
                textView.textAlignment = NSTextAlignment.Left
                cell.mediaContainer.addSubview(textView)
                
                //url of image
                //var urlString : String = localPostItem.lp_file_name as! String
                var urlString : String = localPostItem.lp_preview_file_name as! String
                urlString = YellrConstants.API.endPoint + "/media/" + urlString
                
                //work around temp
                if (postType == "audio") {
                    urlString = "http://i.imgur.com/WUzhfKp.jpg"
                }
                if (postType == "video") {
                    urlString = "http://i.imgur.com/XgGMT85.png"
                }
                
                //MARK: Version 2 - With Image Cache
                
                //to get the height of the text view holding the caption
                let calculationView : UITextView = UITextView()
                let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(18.0)]
                calculationView.attributedText = NSAttributedString(string: textView.text, attributes: attrs)
                let size : CGSize = calculationView.sizeThatFits(CGSizeMake(UIScreen.mainScreen().bounds.size.width - 75.0, 3.40282347E+38))
                
                if self.imageCache.objectForKey(urlString) != nil {
                    let itemImage = self.imageCache.objectForKey(urlString) as? UIImage
                    let imageView = UIImageView(image: itemImage!)
                    imageView.frame = CGRect(x: 0, y: size.height, width: UIScreen.mainScreen().bounds.size.width - 75.0, height: cell.mediaContainer.frame.height + 60.0)
                    imageView.contentMode = UIViewContentMode.ScaleAspectFill
                    //to make the ScaleAspectFill work perfectly, need to set the clipsToBounds property
                    imageView.clipsToBounds = true
                    imageView.hidden = false
                    cell.mediaContainer.addSubview(imageView)
                    cell.setNeedsLayout()
                }
                else {
                    
                    //start a loader animation
                    let loadIndicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                    loadIndicator.color = UIColor.lightGrayColor()
                    loadIndicator.startAnimating()
                    cell.mediaContainer.addSubview(loadIndicator)
                    
                    //start the image load process
                    weak var weakSelf : LocalTableViewController? = self
        
                    dispatch_async(self.backgroundQueue, { () -> Void in
        
                        let url = NSURL(string: urlString)!
                        let capturedIndex : NSIndexPath? = indexPath.copy() as? NSIndexPath
                        var err : NSError?
                        var imageData : NSData?
                        do {
                            imageData = try NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                        } catch let error as NSError {
                            err = error
                            imageData = nil
                        } catch {
                            fatalError()
                        }
        
                        if err == nil {
        
                            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
        
                                let itemImage = UIImage(data:imageData!)
                                //itemImage = ResizeImage(itemImage!, CGSize(width: UIScreen.mainScreen().bounds.size.width - 75.0, height: cell.mediaContainer.frame.height))
                                
                                Yellr.println(itemImage!.size.width)
                                Yellr.println(itemImage!.size.height)
                                
                                let currentIndex = self.tableView.indexPathForCell(cell)
        
                                if currentIndex?.item == capturedIndex!.item {
                                    
                                    let imageView = UIImageView(image: itemImage!)
                                    imageView.frame = CGRect(x: 0, y: size.height, width: UIScreen.mainScreen().bounds.size.width - 75.0, height: cell.mediaContainer.frame.height + 60.0)
                                    imageView.contentMode = UIViewContentMode.ScaleAspectFill
                                    imageView.clipsToBounds = true
                                    imageView.hidden = false
                                    
                                    //add the image view
                                    cell.mediaContainer.addSubview(imageView)
                                    cell.setNeedsLayout()
                                    
                                    //remove the activity indicator
                                    loadIndicator.removeFromSuperview()
                                    
                                    //cell.imageView.image = itemImage
                                    //cell.setNeedsLayout()
                                }
                                weakSelf!.imageCache.setObject(itemImage!, forKey: urlString)
                            })
                        }
                    })
                }
                
//MARK: Version 1 - Download Image, No Cache
//                dispatch_async(self.backgroundQueue, { () -> Void in
//                    
//                    /* capture the index of the cell that is requesting this image download operation */
//                    var capturedIndex : NSIndexPath? = indexPath.copy() as? NSIndexPath
//                    
//                    var err : NSError?
//                    /* get url for image and download raw data */
//                    let url = NSURL(string: urlString)!
//                    var imageData : NSData? = NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)
//                    
//                    if err == nil {
//                        
//                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
//                            
//                            /* create a UIImage object from the downloaded data */
//                            let itemImage = UIImage(data:imageData!)
//                            /* get the index of one of the cells that is currently being displayed */
//                            let currentIndex = self.tableView.indexPathForCell(cell)
//                            
//                            // compare the captured cell index to some current cell index       //
//                            // if the captured cell index is equal to some current cell index   //
//                            // then the cell that requested the image is still on the screen so //
//                            // we present the downloaded image else we do nothing               //
//                            if currentIndex?.item == capturedIndex!.item {
//                                let imageView = UIImageView(image: itemImage!)
//                                imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 80)
//                                imageView.hidden = false
//                                cell.mediaContainer.addSubview(imageView)
//                                cell.setNeedsLayout()
//                            }
//                        })
//                    }
//                })
                
            }
        } else {
            
        }
        
        //show small arrow towards the right of each cell
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    
    }
    
    func upVoteClicked(sender: UIButton?) {
        
        //get the cell in which the button was clicked
        let indexPath = NSIndexPath(forRow: sender!.tag, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! LocalTableViewCell
        
        var localPostItem : LocalPostDataModel = self.dataSource[indexPath.row]
        //api needs string postID
        var postId = NSString(format:"%d", (stringInterpolationSegment: (localPostItem.lp_post_id as? Int)!)) as String
        //send to api
        post(["post_id":postId, "is_up_vote":"1"], method: "register_vote", latitude: self.lat, longitude: self.long) { (succeeded: Bool, msg: String) -> () in
            Yellr.println(msg)
            //TODO: apply response results to button pressess
            //currently we are changing UI feedback assuming that
            //request will always succeed
        }
        
        if let hasVoted = localPostItem.lp_has_voted as? Bool {
            
            if (hasVoted) {
                
                var isUpVote : Bool = (localPostItem.lp_is_up_vote as? Bool)!
                
                if (isUpVote) {
                    
                    //upvote being removed
                    cell.upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                    cell.downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                    
                    //remove vote
                    localPostItem.lp_has_voted = 0
                    
                    //update vote count
                    var getCurrentUpvoteCount = Int(cell.upVoteCount.text!)
                    cell.upVoteCount?.text = String(getCurrentUpvoteCount! - 1)
                    
                } else {
                    
                    //changing down vote to up vote
                    cell.upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.up_vote_green)
                    cell.downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                cell.upVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.up_vote_green), forState: .Normal)
                    
                    //register the up vote
                    localPostItem.lp_is_up_vote = 1
                    
                    // update up vote count
                    var getCurrentUpvoteCount = Int(cell.upVoteCount.text!)
                    cell.upVoteCount?.text = String(getCurrentUpvoteCount! + 1)
                    
                    // update down vote count
                    var getCurrentDownvoteCount = Int(cell.downVoteCount.text!)
                    cell.downVoteCount?.text = String(getCurrentDownvoteCount! - 1)
                    
                }
                
            } else {
                
                //first time voting
                cell.upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.up_vote_green)
                cell.downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                cell.upVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.up_vote_green), forState: .Normal)
                
                localPostItem.lp_has_voted = 1
                localPostItem.lp_is_up_vote = 1
                
                //update vote count
                var getCurrentUpvoteCount = Int(cell.upVoteCount.text!)
                cell.upVoteCount?.text = String(getCurrentUpvoteCount! + 1)
                
            }
            
        } else {
            
        }
        
    }
    
    func downVoteClicked(sender: UIButton?) {
        //get the cell in which the button was clicked
        let indexPath = NSIndexPath(forRow: sender!.tag, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! LocalTableViewCell
        
        var localPostItem : LocalPostDataModel = self.dataSource[indexPath.row]
        //api needs string postID
        var postId = NSString(format:"%d", (stringInterpolationSegment: (localPostItem.lp_post_id as? Int)!)) as String
        //send to api
        post(["post_id":postId, "is_up_vote":"0"], method: "register_vote", latitude: self.lat, longitude: self.long) { (succeeded: Bool, msg: String) -> () in
            Yellr.println(msg)
        }
        
        if let hasVoted = localPostItem.lp_has_voted as? Bool {
            
            if (hasVoted) {
                
                var isUpVote : Bool = (localPostItem.lp_is_up_vote as? Bool)!
                
                if (isUpVote) {
                    
                    //downvote being removed
                    cell.upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                    cell.downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                    
                    //remove vote
                    localPostItem.lp_has_voted = 0
                    
                    //update downvote count
                    var getCurrentDownvoteCount = Int(cell.downVoteCount.text!)
                    cell.upVoteCount?.text = String(getCurrentDownvoteCount! - 1)
                    
                } else {
                    
                    //changing up vote to down vote
                    cell.upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                    cell.downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.down_vote_red)
                    cell.downVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.down_vote_red), forState: .Normal)
                    
                    //register the up vote
                    localPostItem.lp_is_up_vote = 0
                    
                    // update up vote count
                    var getCurrentUpvoteCount = Int(cell.upVoteCount.text!)
                    cell.upVoteCount?.text = String(getCurrentUpvoteCount! - 1)
                    
                    // update down vote count
                    var getCurrentDownvoteCount = Int(cell.downVoteCount.text!)
                    cell.downVoteCount?.text = String(getCurrentDownvoteCount! + 1)
                    
                }
                
            } else {
                
                //first time down voting
                cell.upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                cell.downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.down_vote_red)
                cell.downVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.down_vote_red), forState: .Normal)
                localPostItem.lp_has_voted = 1
                localPostItem.lp_is_up_vote = 0
                
                //update down vote count
                var getCurrentDownvoteCount = Int(cell.downVoteCount.text!)
                cell.downVoteCount?.text = String(getCurrentDownvoteCount! - 1)
                
            }
            
        } else {
            
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if (segue.identifier == "LocalPostDetailSegue") {
            
            let indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow!
            let localPostItem:LocalPostDataModel = self.dataSource[indexPath.row]
            let viewController = segue.destinationViewController as! LocalPostDetailViewController
            viewController.localPostItem = localPostItem
            viewController.title = localPostItem.lp_media_text as? String
            viewController.storyId = localPostItem.lp_post_id as? Int
            viewController.lat = self.lat
            viewController.long = self.long
            
            dispatch_async(dispatch_get_main_queue()!, { () -> Void in
                //for the questionmark
                let attrs = [NSFontAttributeName : UIFont.fontAwesome(size: 13)]
                //var qmString = NSMutableAttributedString(string:"\(String.fontAwesome(unicode: 0xf059)) ", attributes:attrs)
                
                if let postTitle = localPostItem.lp_question_text as? String {
                    
                    viewController.postTitle?.text = "\(String.fontAwesome(unicode: 0xf059)) " + postTitle
                    viewController.postTitle?.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    viewController.postTitle?.numberOfLines = 0
                    viewController.postTitle?.sizeToFit()
                    
                } else {
                    viewController.postTitle?.text = ""
                }
                
                if let author = localPostItem.lp_first_name as? String {
                    viewController.postedBy?.text = author
                } else {
                    viewController.postedBy?.font = UIFont.fontAwesome(size: 13)
                    viewController.postedBy?.text = "\(String.fontAwesome(unicode: 0xf007)) " + NSLocalizedString(YellrConstants.LocalPosts.AnonymousUser, comment: "Anonymous User")
                }
                
                let postedOn:String = (localPostItem.lp_post_datetime as? String)!
                viewController.postedOn?.font = UIFont.fontAwesome(size: 13)
                viewController.postedOn?.text = "\(String.fontAwesome(unicode: 0xf040)) " + postedOn
                
                viewController.upVoteCount?.text = NSString(format:"%d", (stringInterpolationSegment: (localPostItem.lp_up_vote_count as? Int)!)) as String
                //add - (negative to downvote counts)
                let downVoteCount = (localPostItem.lp_down_vote_count as? Int)!
                var downVoteCountString = NSString(format:"%d", (stringInterpolationSegment: downVoteCount)) as String
                if (downVoteCount != 0) {
                    downVoteCountString = "-" + downVoteCountString
                }
                viewController.downVoteCount?.text = downVoteCountString
                
                //set vote count colors based on whether or not user has voted
                if let hasVoted = localPostItem.lp_has_voted as? Bool {
                    if (hasVoted) {
                        let isUpVote : Bool = (localPostItem.lp_is_up_vote as? Bool)!
                        viewController.hasVoted = "Yes"
                        if (isUpVote) {
                            viewController.upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.up_vote_green)
                            viewController.upVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.up_vote_green), forState: .Normal)
                            viewController.downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                            viewController.isUpVote = "Yes"
                        } else {
                            viewController.upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                            viewController.downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.down_vote_red)
                            viewController.downVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.down_vote_red), forState: .Normal)
                            viewController.isUpVote = "No"
                        }
                    } else {
                        viewController.upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                        viewController.downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                    }
                } else {
                    
                }
                
                if let postType = localPostItem.lp_media_type_name as? String {
                    if (postType == "text") {
                        
                        let textView = UITextView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width - 75.0, viewController.mediaContainer.frame.height))
                        textView.text = localPostItem.lp_media_text as? String
                        textView.font = UIFont(name: "ArialMT", size: 17.0)
                        textView.hidden = false
                        textView.sizeToFit()
                        textView.scrollEnabled = false
                        textView.editable = false
                        textView.selectable = false
                        textView.textAlignment = NSTextAlignment.Left
                        viewController.mediaContainer.addSubview(textView)
                        viewController.mediaContainer.hidden = false
                        
                    }
                    
                    if (postType == "audio") {
                        
                        viewController.mediaContainer.hidden = false
                        
                        let textView = UITextView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width - 75.0, viewController.mediaContainer.frame.height))
                        textView.text = localPostItem.lp_media_caption as? String
                        textView.font = UIFont(name: "ArialMT", size: 17.0)
                        textView.hidden = false
                        textView.sizeToFit()
                        textView.scrollEnabled = false
                        textView.editable = false
                        textView.selectable = false
                        textView.textAlignment = NSTextAlignment.Left
                        viewController.mediaContainer.addSubview(textView)
                        
                        var urlString = localPostItem.lp_file_name as! String
                        urlString = YellrConstants.API.endPoint + "/media/" + urlString
                        
                        let url:NSURL = NSURL(string: urlString)!
                        Yellr.println(urlString)
                        
                        self.moviePlayer = MPMoviePlayerController(contentURL: url)
                        self.moviePlayer.prepareToPlay()
                        self.moviePlayer.contentURL = url
                        self.moviePlayer.view.frame = viewController.mediaContainer.bounds
                        viewController.mediaContainer.addSubview(self.moviePlayer.view)
                        self.moviePlayer.play()
                        
                    }
                    
                    if (postType == "video") {
                        
                        viewController.mediaContainer.hidden = false
                        
                        let textView = UITextView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width - 75.0, viewController.mediaContainer.frame.height))
                        textView.text = localPostItem.lp_media_caption as? String
                        textView.font = UIFont(name: "ArialMT", size: 17.0)
                        textView.hidden = false
                        textView.sizeToFit()
                        textView.scrollEnabled = false
                        textView.editable = false
                        textView.selectable = false
                        textView.textAlignment = NSTextAlignment.Left
                        viewController.mediaContainer.addSubview(textView)
                        
                        var urlString = localPostItem.lp_file_name as! String
                        urlString = YellrConstants.API.endPoint + "/media/" + urlString
                        
                        let url:NSURL = NSURL(string: urlString)!
                        Yellr.println(urlString)
                        
                        self.moviePlayer = MPMoviePlayerController(contentURL: url)
                        self.moviePlayer.prepareToPlay()
                        self.moviePlayer.contentURL = url
                        self.moviePlayer.view.frame = viewController.mediaContainer.bounds
                        viewController.mediaContainer.addSubview(self.moviePlayer.view)
                        self.moviePlayer.play()
                        
                        //TODO: Download and then play video
//                        HttpDownloader.loadFileAsync(url, completion:{(path:String, error:NSError!) in
//                            Yellr.println("downloaded to: \(path)")
//                            Yellr.println(NSURL(string: path)!)
//
//                        })
                        
                        
                    }
                    
                    if (postType == "image") {
                        
                        viewController.mediaContainer.hidden = false
                        
                        let textView = UITextView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width - 75.0, viewController.mediaContainer.frame.height))
                        textView.text = localPostItem.lp_media_caption as? String
                        textView.font = UIFont(name: "ArialMT", size: 17.0)
                        textView.hidden = false
                        textView.sizeToFit()
                        textView.scrollEnabled = false
                        textView.editable = false
                        textView.selectable = false
                        textView.textAlignment = NSTextAlignment.Left
                        viewController.mediaContainer.addSubview(textView)
                        
                        //url of image
                        var urlString : String = localPostItem.lp_file_name as! String
                        urlString = YellrConstants.API.endPoint + "/media/" + urlString
                        
                        //MARK: Version 2 - With Image Cache
                        
                        //to get the height of the text view holding the caption
                        let calculationView : UITextView = UITextView()
                        let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(18.0)]
                        calculationView.attributedText = NSAttributedString(string: textView.text, attributes: attrs)
                        let size : CGSize = calculationView.sizeThatFits(CGSizeMake(UIScreen.mainScreen().bounds.size.width - 75.0, 3.40282347E+38))
                        
                        if self.imageCache.objectForKey(urlString) != nil {
                            let itemImage = self.imageCache.objectForKey(urlString) as? UIImage
                            let imageView = UIImageView(image: itemImage!)
                            imageView.frame = CGRect(x: 0, y: size.height, width: UIScreen.mainScreen().bounds.size.width - 75.0, height: viewController.mediaContainer.frame.height)
                            imageView.contentMode = UIViewContentMode.ScaleAspectFill
                            imageView.clipsToBounds = true
                            imageView.hidden = false
                            viewController.mediaContainer.addSubview(imageView)
                            Yellr.println("here44")
                            //cell.setNeedsLayout()
                        }
                        else {
                            
                            //start a loader animation
                            let loadIndicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                            loadIndicator.color = UIColor.lightGrayColor()
                            loadIndicator.startAnimating()
                            viewController.mediaContainer.addSubview(loadIndicator)
                            
                            //start the image load process
                            weak var weakSelf : LocalTableViewController? = self
                            
                            dispatch_async(self.backgroundQueue, { () -> Void in
                                
                                let url = NSURL(string: urlString)!
                                let capturedIndex : NSIndexPath? = indexPath.copy() as? NSIndexPath
                                var err : NSError?
                                var imageData : NSData?
                                do {
                                    imageData = try NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                                } catch let error as NSError {
                                    err = error
                                    imageData = nil
                                } catch {
                                    fatalError()
                                }
                                
                                if err == nil {
                                    
                                    dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                                        
                                        let itemImage = UIImage(data:imageData!)
                                        //itemImage = ResizeImage(itemImage!, CGSize(width: UIScreen.mainScreen().bounds.size.width - 75.0, height: viewController.mediaContainer.frame.height))
                                        
                                        Yellr.println(itemImage!.size.width)
                                        Yellr.println(itemImage!.size.height)
                                        
                                        let currentIndex = indexPath
                                        
                                        if currentIndex.item == capturedIndex!.item {
                                            
                                            //let imageView = UIImageView(image: itemImage!)
                                            let imageView = UIImageView()
                                            imageView.frame = CGRect(x: 0, y: size.height, width: UIScreen.mainScreen().bounds.size.width - 75.0, height: viewController.mediaContainer.frame.height)
                                            
                                            imageView.contentMode = .ScaleAspectFit
                                            imageView.image = itemImage
                                            imageView.clipsToBounds = true
                                            
                                            //imageView.contentMode = UIViewContentMode.ScaleAspectFit
                                            //                                    imageView.autoresizingMask =
                                            //                                        (UIViewAutoresizing.FlexibleLeftMargin
                                            //                                            | UIViewAutoresizing.FlexibleRightMargin
                                            //                                            | UIViewAutoresizing.FlexibleTopMargin
                                            //                                            | UIViewAutoresizing.FlexibleWidth)
                                            imageView.hidden = false
                                            
                                            //add the image view
                                            viewController.mediaContainer.addSubview(imageView)
                                            
                                            //remove the activity indicator
                                            loadIndicator.removeFromSuperview()
                                            
                                            //cell.imageView.image = itemImage
                                            //cell.setNeedsLayout()
                                        }
                                        weakSelf!.imageCache.setObject(itemImage!, forKey: urlString)
                                    })
                                }
                            })
                        }
                        
                    }
                } else {
                    
                }
                
                //viewController.mediaContainer.
            })
            
        }
    }
    
    func initWebActivityIndicator() {
        self.webActivityIndicator.color = UIColor.lightGrayColor()
        self.webActivityIndicator.startAnimating()
        self.webActivityIndicator.center = self.view.center
        self.view.addSubview(self.webActivityIndicator)
    }
    
    // MARK: - Networking
    func requestLocalPosts(endPointURL : String, responseHandler : (error : NSError? , items : Array<LocalPostDataModel>?) -> () ) -> () {

        let url:NSURL = NSURL(string: endPointURL)!
        let task = self.urlSession.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            
            Yellr.println(response)
            Yellr.println(error)
            
            if (error == nil) {
                responseHandler( error: nil, items: self.localPostItems(data!))
            } else {
                Yellr.println(error)
            }

        })
        task.resume()
    }
    
    func localPostItems(data: NSData) -> (Array<LocalPostDataModel>) {
        var jsonParseError: NSError?
        var refinedLocalPostItems : Array<LocalPostDataModel> = []
        var postListString : String
        
        do {
            if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
             
                let rawLocalPostItems = jsonResult["posts"] as! Array<Dictionary<String,AnyObject>>
                
                Yellr.println(jsonResult["posts"])
                
                for itemDict in rawLocalPostItems {
                    var lpfname : String = ""
                    var lpmtext : String = ""
                    var lpmtname : String = ""
                    var lppfname : String = ""
                    var lpmdcpt : String = ""
                    let mediaItems = itemDict["media_objects"] as! Array<Dictionary<String,String>>
                    
                    for itemDictMedia in mediaItems {
                        lpfname = itemDictMedia["file_name"]!
                        lpmtext = itemDictMedia["media_text"]!
                        lpmtname = itemDictMedia["media_type_name"]!
                        lppfname = itemDictMedia["preview_file_name"]!
                        lpmdcpt = itemDictMedia["caption"]!
                    }
                    
                    let item : LocalPostDataModel = LocalPostDataModel(lp_last_name: itemDict["last_name"],
                        lp_language_code : itemDict["last_name"],
                        lp_post_id : itemDict["post_id"],
                        lp_verified_user : itemDict["verified_user"],
                        lp_post_datetime : itemDict["post_datetime_ago"],
                        
                        lp_file_name : lpfname,
                        lp_media_text : lpmtext,
                        lp_media_type_name : lpmtname,
                        lp_preview_file_name : lppfname,
                        lp_media_caption : lpmdcpt,
                        
                        lp_first_name : itemDict["first_name"],
                        lp_question_text : itemDict["question_text"],
                        lp_is_up_vote : itemDict["is_up_vote"],
                        lp_down_vote_count : itemDict["down_vote_count"],
                        lp_has_voted : itemDict["has_voted"],
                        lp_language_name : itemDict["language_name"],
                        lp_up_vote_count : itemDict["up_vote_count"] )
                    
                    refinedLocalPostItems.append(item)
                    //postListString = "[" + (itemDict["post_id"] as? String)! + "]"
                }
                
            } else {
                
            }
        } catch _ {
        
        }
        return refinedLocalPostItems
    }
    
    //MARK: Location Delegate functions
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: AnyObject = locations[locations.count - 1]
        
        let latitude : String = String(format: "%.2f", latestLocation.coordinate.latitude)
        let longitude : String = String(format: "%.2f", latestLocation.coordinate.longitude)
        
        self.lat = latitude
        self.long = longitude
        
        //store lat long in prefs
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(self.lat, forKey: YellrConstants.Direction.Latitude)
        defaults.setObject(self.long, forKey: YellrConstants.Direction.Longitude)
        defaults.synchronize()        
        
        self.loadLocalPostsTableView(latitude, longitude: longitude)
        locationManager.stopUpdatingLocation()
        
        //TODO: Store Lat Long in userprefs
        //TODO: stopUpdatingLocation should be called after a couple of seconds from
        //receiving the first location
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        Yellr.println(error)
        let alert = UIAlertView()
        alert.title = NSLocalizedString(YellrConstants.Location.Title, comment: "Location Error Title")
        alert.message = NSLocalizedString(YellrConstants.Location.Message, comment: "Location Error Message")
        alert.addButtonWithTitle(NSLocalizedString(YellrConstants.Location.Okay, comment: "Okay"))
        alert.show()
    }
    
    func messageForFirstTimer() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let name = defaults.stringForKey(YellrConstants.Keys.FirstTimeUserKey) {
            
            //Not a first time user
            
        } else {
            
            //first time user of the app
            if #available(iOS 8.0, *) {
                
                let alertController = UIAlertController(title: NSLocalizedString(YellrConstants.LocalPosts.FirstTimeTitle, comment: "LocalPosts Screen - Succesfully Posted"), message:
                    NSLocalizedString(YellrConstants.LocalPosts.FirstTimeMessage, comment: "LocalPosts Screen Message Succesful"), preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString(YellrConstants.LocalPosts.FirstTimeOkay, comment: "Okay"), style: UIAlertActionStyle.Default, handler: { (action) in
                    //dismiss the add post view on pressing okay
                    self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    ))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            } else {
                
                let alert = UIAlertView()
                alert.tag = 0
                alert.delegate = self
                alert.title = NSLocalizedString(YellrConstants.LocalPosts.FirstTimeTitle, comment: "LocalPosts Screen - Succesfully Posted")
                alert.message = NSLocalizedString(YellrConstants.LocalPosts.FirstTimeMessage, comment: "LocalPosts Screen Message Succesful")
                alert.addButtonWithTitle(NSLocalizedString(YellrConstants.LocalPosts.FirstTimeOkay, comment: "Okay"))
                alert.show()
                
            }
            
            defaults.setObject("NO", forKey: YellrConstants.Keys.FirstTimeUserKey)
            defaults.synchronize()
            
        }
        
    }
    
    
}

