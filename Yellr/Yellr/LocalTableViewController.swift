//
//  LocalTableViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 5/29/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit
import CoreLocation

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
    
    var lat: String = ""
    var long: String = ""
    
    var containerWidth: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString(YellrConstants.LocalPosts.Title, comment: "Local Post Screen title")
        self.initWebActivityIndicator()
        
        //right side bar button items
        var profileBarButtonItem:UIBarButtonItem = UIBarButtonItem(fontAwesome: "f007", target: self, action: "profileTapped:")
        var fixedSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        fixedSpace.width = 30.0
        var addPostBarButtonItem:UIBarButtonItem = UIBarButtonItem(fontAwesome: "f044", target: self, action: "addPostTapped:")
        self.navigationItem.setRightBarButtonItems([addPostBarButtonItem, fixedSpace, profileBarButtonItem], animated: true)
        
        //left barbutton item
        var yellrBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: YellrConstants.AppInfo.Name, style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationItem.setLeftBarButtonItems([yellrBarButtonItem], animated: true)

    }
    
    //for the yellow underline bars on selected tabs
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let subViews = self.tabBarController!.tabBar.subviews
        for subview in subViews{
            if (subview.tag == 1201) {
                (subview as? UIView)!.hidden = false
            } else if (subview.tag == 1202) {
                (subview as? UIView)!.hidden = true
            } else if (subview.tag == 1203) {
                (subview as? UIView)!.hidden = true
            }
        }
        
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
        
        var localPostItem : LocalPostDataModel = self.dataSource[indexPath.row]
        var height:CGFloat = 120.0
        var calculationView : UITextView = UITextView()
        
        if let text = localPostItem.lp_media_text as? String {
            if (count(text) == 0) {
                height += 140.0
            } else {

                var attrs = [NSFontAttributeName : UIFont.systemFontOfSize(18.0)]
                calculationView.attributedText = NSAttributedString(string: text, attributes: attrs)
                var size : CGSize = calculationView.sizeThatFits(CGSizeMake(UIScreen.mainScreen().bounds.size.width - 75.0, 3.40282347E+38))
                height += size.height
            }
            
        }
        
        return height + 20
        
        
        
        
//        var sizingCell : LocalTableViewCell
//        var onceToken : dispatch_once_t
//
//        dispatch_once(&onceToken, { () -> Void in
//            sizingCell = tableView.dequeueReusableCellWithIdentifier("LocalTVCIdentifier", forIndexPath: indexPath) as! LocalTableViewCell
//        })
//        
//        var mo : ModelObject = self.model[indexPath.row]
//        
//        // 3
//        CGFloat (^calcCellHeight)(MyTableViewCell *, NSString *) = ^ CGFloat(MyTableViewCell *sizingCell, NSString *labelText){
//            
//            sizingCell.customLabel.text = labelText;
//            
//            return [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1;
//        };
//        
//        NSUInteger ix = indexPath.row;
//        
//        // 4
//        if ([self.cachedHeights[ix] isEqual:[NSNull null]]){
//            
//            CGFloat cellHeight = calcCellHeight(sizingCell, mo.customStringProperty);
//            
//            self.cachedHeights[ix] = @(cellHeight);
//        }
//        
//        // 5  
//        return ([self.cachedHeights[ix] floatValue] < MyMinimumCellHeight) ?
//            MyMinimumCellHeight : [self.cachedHeights[ix] floatValue];

        
        
        
        
    }
    
    //when profile button is tapped in UINavBar
    func profileTapped(sender:UIButton) {
        self.performSegueWithIdentifier("LocalToProfile", sender: self)
    }
    
    //when add post button is tapped in UINavBar
    func addPostTapped(sender:UIButton) {
        self.performSegueWithIdentifier("LocalToPost", sender: self)
    }
    
    //starts the tableviewload process
    //api call and then populate
    func loadLocalPostsTableView(latitude : String, longitude : String) {
        
        self.localPostsUrlEndpoint = buildUrl("get_local_posts.json", latitude, longitude)
        self.requestLocalPosts(self.localPostsUrlEndpoint, responseHandler: { (error, items) -> () in
            //TODO: update UI code here
            //Yellr.println("1")
            
        })
    }
    
    func configureCell(cell:LocalTableViewCell, atIndexPath indexPath:NSIndexPath) {
        
        var localPostItem : LocalPostDataModel = self.dataSource[indexPath.row]
        
        for view in cell.mediaContainer.subviews{
            view.removeFromSuperview()
        }
        
        //set the button tags for upvote and downvote buttons
        cell.upVoteBtn.tag = indexPath.row
        cell.downVoteBtn.tag = indexPath.row
        
        cell.upVoteBtn.addTarget(self, action: "upVoteClicked:", forControlEvents: .TouchUpInside)
        cell.downVoteBtn.addTarget(self, action: "downVoteClicked:", forControlEvents: .TouchUpInside)
        
        //for the questionmark
        var attrs = [NSFontAttributeName : UIFont.fontAwesome(size: 13)]
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
        
        var postedOn:String = (localPostItem.lp_post_datetime as? String)!
        cell.postedOn?.font = UIFont.fontAwesome(size: 13)
        cell.postedOn?.text = "\(String.fontAwesome(unicode: 0xf040)) " + postedOn
        
        cell.upVoteCount?.text = NSString(format:"%d", (stringInterpolationSegment: (localPostItem.lp_up_vote_count as? Int)!)) as String
        //add - (negative to downvote counts)
        var downVoteCount = (localPostItem.lp_down_vote_count as? Int)!
        var downVoteCountString = NSString(format:"%d", (stringInterpolationSegment: downVoteCount)) as String
        if (downVoteCount != 0) {
            downVoteCountString = "-" + downVoteCountString
        }
        cell.downVoteCount?.text = downVoteCountString
        
        //set vote count colors based on whether or not user has voted
        if let hasVoted = localPostItem.lp_has_voted as? Bool {
            if (hasVoted) {
                var isUpVote : Bool = (localPostItem.lp_is_up_vote as? Bool)!
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
            
            if (postType == "image") {
                
                cell.mediaContainer.hidden = false
                
                let textView = UITextView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width - 75.0, cell.mediaContainer.frame.height))
                textView.text = localPostItem.lp_media_caption as? String
                textView.hidden = false
                textView.sizeToFit()
                textView.scrollEnabled = false
                textView.editable = false
                textView.selectable = false
                textView.textAlignment = NSTextAlignment.Left
                cell.mediaContainer.addSubview(textView)
                
                //url of image
                var urlString : String = localPostItem.lp_file_name as! String
                urlString = YellrConstants.API.endPoint + "/media/" + urlString
                
                //MARK: Version 2 - With Image Cache
        
                if self.imageCache.objectForKey(urlString) != nil {
                    let itemImage = self.imageCache.objectForKey(urlString) as? UIImage
                    let imageView = UIImageView(image: itemImage!)
                    imageView.frame = CGRect(x: 0, y: 30, width: UIScreen.mainScreen().bounds.size.width - 75.0, height: cell.mediaContainer.frame.height + 60.0)
                    imageView.contentMode = UIViewContentMode.ScaleAspectFit
                    imageView.hidden = false
                    cell.mediaContainer.addSubview(imageView)
                    cell.setNeedsLayout()
                }
                else {
                    
                    //start a loader animation
                    var loadIndicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                    loadIndicator.color = UIColor.lightGrayColor()
                    loadIndicator.startAnimating()
                    cell.mediaContainer.addSubview(loadIndicator)
                    
                    //start the image load process
                    weak var weakSelf : LocalTableViewController? = self
        
                    dispatch_async(self.backgroundQueue, { () -> Void in
        
                        let url = NSURL(string: urlString)!
                        var capturedIndex : NSIndexPath? = indexPath.copy() as? NSIndexPath
                        var err : NSError?
                        var imageData : NSData? = NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)
        
                        if err == nil {
        
                            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
        
                                let itemImage = UIImage(data:imageData!)
                                let currentIndex = self.tableView.indexPathForCell(cell)
        
                                if currentIndex?.item == capturedIndex!.item {
                                    
                                    let imageView = UIImageView(image: itemImage!)
                                    imageView.frame = CGRect(x: 0, y: 30, width: UIScreen.mainScreen().bounds.size.width - 75.0, height: cell.mediaContainer.frame.height + 60.0)
                                    imageView.contentMode = UIViewContentMode.ScaleAspectFit
//                                    imageView.autoresizingMask =
//                                        (UIViewAutoresizing.FlexibleLeftMargin
//                                            | UIViewAutoresizing.FlexibleRightMargin
//                                            | UIViewAutoresizing.FlexibleTopMargin
//                                            | UIViewAutoresizing.FlexibleWidth)
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
        //cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    
    }
    
    func upVoteClicked(sender: UIButton?) {
        
        //get the cell in which the button was clicked
        let indexPath = NSIndexPath(forRow: sender!.tag, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! LocalTableViewCell
        
        var localPostItem : LocalPostDataModel = self.dataSource[indexPath.row]
        //api needs string postID
        var postId = NSString(format:"%d", (stringInterpolationSegment: (localPostItem.lp_post_id as? Int)!)) as String
        //send to api
        post(["post_id":postId, "is_up_vote":"1"], "register_vote", self.lat, self.long) { (succeeded: Bool, msg: String) -> () in
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
                    var getCurrentUpvoteCount = cell.upVoteCount?.text?.toInt()
                    cell.upVoteCount?.text = String(getCurrentUpvoteCount! - 1)
                    
                } else {
                    
                    //changing down vote to up vote
                    cell.upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.up_vote_green)
                    cell.downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                cell.upVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.up_vote_green), forState: .Normal)
                    
                    //register the up vote
                    localPostItem.lp_is_up_vote = 1
                    
                    // update up vote count
                    var getCurrentUpvoteCount = cell.upVoteCount?.text?.toInt()
                    cell.upVoteCount?.text = String(getCurrentUpvoteCount! + 1)
                    
                    // update down vote count
                    var getCurrentDownvoteCount = cell.downVoteCount?.text?.toInt()
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
                var getCurrentUpvoteCount = cell.upVoteCount?.text?.toInt()
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
        post(["post_id":postId, "is_up_vote":"0"], "register_vote", self.lat, self.long) { (succeeded: Bool, msg: String) -> () in
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
                    var getCurrentDownvoteCount = cell.downVoteCount?.text?.toInt()
                    cell.upVoteCount?.text = String(getCurrentDownvoteCount! - 1)
                    
                } else {
                    
                    //changing up vote to down vote
                    cell.upVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
                    cell.downVoteCount.textColor = UIColorFromRGB(YellrConstants.Colors.down_vote_red)
                    cell.downVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.down_vote_red), forState: .Normal)
                    
                    //register the up vote
                    localPostItem.lp_is_up_vote = 0
                    
                    // update up vote count
                    var getCurrentUpvoteCount = cell.upVoteCount?.text?.toInt()
                    cell.upVoteCount?.text = String(getCurrentUpvoteCount! - 1)
                    
                    // update down vote count
                    var getCurrentDownvoteCount = cell.downVoteCount?.text?.toInt()
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
                var getCurrentDownvoteCount = cell.downVoteCount?.text?.toInt()
                cell.downVoteCount?.text = String(getCurrentDownvoteCount! - 1)
                
            }
            
        } else {
            
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
            
            //Yellr.println(response)
            //Yellr.println(error)
            
            if (error == nil) {
                self.dataSource = self.localPostItems(data)
                
                dispatch_async(dispatch_get_main_queue()!, { () -> Void in
                    self.tableView.reloadData()
                    self.webActivityIndicator.hidden = true
                })
                
                responseHandler( error: nil, items: nil)
            } else {
                Yellr.println(error)
            }

        })
        task.resume()
    }
    
    func localPostItems(data: NSData) -> (Array<LocalPostDataModel>) {
        var jsonParseError: NSError?
        var refinedLocalPostItems : Array<LocalPostDataModel> = []
        
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonParseError) as? NSDictionary {
         
            var rawLocalPostItems = jsonResult["posts"] as! Array<Dictionary<String,AnyObject>>
            
            for itemDict in rawLocalPostItems {
                var lpfname : String = ""
                var lpmtext : String = ""
                var lpmtname : String = ""
                var lppfname : String = ""
                var lpmdcpt : String = ""
                var mediaItems = itemDict["media_objects"] as! Array<Dictionary<String,String>>
                
                for itemDictMedia in mediaItems {
                    lpfname = itemDictMedia["file_name"]!
                    lpmtext = itemDictMedia["media_text"]!
                    lpmtname = itemDictMedia["media_type_name"]!
                    lppfname = itemDictMedia["preview_file_name"]!
                    lpmdcpt = itemDictMedia["caption"]!
                }
                
                var item : LocalPostDataModel = LocalPostDataModel(lp_last_name: itemDict["last_name"],
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
            }
            
        } else {
            
        }
        return refinedLocalPostItems
    }
    
    //MARK: Location Delegate functions
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var latestLocation: AnyObject = locations[locations.count - 1]
        
        var latitude : String = String(format: "%.2f", latestLocation.coordinate.latitude)
        var longitude : String = String(format: "%.2f", latestLocation.coordinate.longitude)
        
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
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        Yellr.println(error)
        let alert = UIAlertView()
        alert.title = NSLocalizedString(YellrConstants.Location.Title, comment: "Location Error Title")
        alert.message = NSLocalizedString(YellrConstants.Location.Message, comment: "Location Error Message")
        alert.addButtonWithTitle(NSLocalizedString(YellrConstants.Location.Okay, comment: "Okay"))
        alert.show()
    }
    
    
}

