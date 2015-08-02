//
//  StoriesTableViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 5/29/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit
import CoreLocation

class StoriesTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    let assgnViewModel = AssignmentsViewModel()
    
    var storiesUrlEndpoint: String = ""
    var dataSource : Array<StoriesDataModel> = []
    var webActivityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    var urlSession = NSURLSession.sharedSession()
    var selectedStory: String!
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString(YellrConstants.Stories.Title, comment: "Stories Screen title")

        //self.loadStoriesTableView()
        
        //right side bar button items
        var profileBarButtonItem:UIBarButtonItem = UIBarButtonItem(fontAwesome: "f007", target: self, action: "profileTapped:")
        var fixedSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        fixedSpace.width = 30.0
        var addPostBarButtonItem:UIBarButtonItem = UIBarButtonItem(fontAwesome: "f044", target: self, action: "addPostTapped:")
        self.navigationItem.setRightBarButtonItems([addPostBarButtonItem, fixedSpace, profileBarButtonItem], animated: true)
        
        //left barbutton item
        var yellrBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: YellrConstants.AppInfo.Name, style: UIBarButtonItemStyle.Plain, target: self, action: "yellrTapped:")
        self.navigationItem.setLeftBarButtonItems([yellrBarButtonItem], animated: true)
        
        //application is becoming active again
        //may be from background or from notification
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "applicationBecameActive:",
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let subViews = self.tabBarController!.tabBar.subviews
        for subview in subViews{
            if (subview.tag == YellrConstants.TagIds.BottomTabLocal) {
                (subview as? UIView)!.hidden = true
            } else if (subview.tag == YellrConstants.TagIds.BottomTabAssignments) {
                (subview as? UIView)!.hidden = true
            } else if (subview.tag == YellrConstants.TagIds.BottomTabStories) {
                (subview as? UIView)!.hidden = false
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StoriesTVCIdentifier", forIndexPath: indexPath) as! StoriesTableViewCell
        configureCell(cell, atIndexPath:indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if (segue.identifier == "StoryDetailSegue") {
            
            var indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow()!
            var viewController = segue.destinationViewController as! StoryDetailViewController
            viewController.story = self.dataSource[indexPath.row].stitle;
            viewController.lname = self.dataSource[indexPath.row].lname;
            viewController.fname = self.dataSource[indexPath.row].fname;
            viewController.content = self.dataSource[indexPath.row].content;
            viewController.publishedOn = self.dataSource[indexPath.row].publish;
            
        }
    }
    
    //when profile button is tapped in UINavBar
    func profileTapped(sender:UIButton) {
        self.performSegueWithIdentifier("StoryToProfile", sender: self)
    }
    
    //when add post button is tapped in UINavBar
    func addPostTapped(sender:UIButton) {
        self.performSegueWithIdentifier("StoryToPost", sender: self)
    }
    
    //when Yellr button is tapped
    func yellrTapped(sender:UIButton) {
        self.tabBarController?.selectedIndex = 0
    }
    
    //class fucntion to return count of new stories fetched
    class func numberOfStories() -> Int {
        
        var latitude = "43.16"
        var longitude = "-77.61"
        var storiesCount = 0
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let ylatitude = defaults.stringForKey(YellrConstants.Direction.Latitude) {
            latitude = ylatitude
        } else {}
        if let ylongitude = defaults.stringForKey(YellrConstants.Direction.Longitude) {
            longitude = ylongitude
        } else {}
        
        var storiesUrlEndpoint = buildUrl("get_stories.json", latitude, longitude)
        
        return storiesCount
    }
    
    //starts the tableviewload process
    //api call and then populate
    func loadStoriesTableView(latitude : String, longitude : String) {
        
        self.initWebActivityIndicator()
        
        self.storiesUrlEndpoint = buildUrl("get_stories.json", latitude, longitude)
        self.requestStories(self.storiesUrlEndpoint, responseHandler: { (error, items) -> () in
            
            self.dataSource = items!
                
            dispatch_async(dispatch_get_main_queue()!, { () -> Void in
                self.tableView.reloadData()
                self.webActivityIndicator.hidden = true
            })
            
        })
    }
    
    func configureCell(cell:StoriesTableViewCell, atIndexPath indexPath:NSIndexPath) {
        
        var storyItem : StoriesDataModel = self.dataSource[indexPath.row]
        
        cell.story.text = storyItem.st_title as? String
        
        var postedByF:String = (storyItem.st_author_first_name as? String)!
        var postedByL:String = (storyItem.st_author_last_name as? String)!
        cell.postedBy?.font = UIFont.fontAwesome(size: 13)
        cell.postedBy?.text =  "\(String.fontAwesome(unicode: 0xf007)) " + postedByF + " " + postedByL
        
        //number of comments - variable name is bad, i know
        var postedOn:String = (storyItem.st_publish_datetime_ago as? String)!
        cell.postedOn?.font = UIFont.fontAwesome(size: 13)
        cell.postedOn?.text =  "\(String.fontAwesome(unicode: 0xf086)) " + postedOn
        
    }
    
    // MARK: - Networking
    func requestStories(endPointURL : String, responseHandler : (error : NSError? , items : Array<StoriesDataModel>?) -> () ) -> () {
        initWebActivityIndicator()
        let url:NSURL = NSURL(string: endPointURL)!
        let task = self.urlSession.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            
            if (error == nil) {
                responseHandler( error: nil, items: self.storyItems(data))
            } else {
                Yellr.println(error)
            }
        })
        task.resume()
    }
    
    func storyItems(data: NSData) -> (Array<StoriesDataModel>) {
        var jsonParseError: NSError?
        var refinedStoryItems : Array<StoriesDataModel> = []
        var storiesCount = 0
        
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonParseError) as? NSDictionary {

            var rawStoryItems = jsonResult["stories"] as! Array<Dictionary<String,AnyObject>>
            
            for itemDict in rawStoryItems {
                
                var item : StoriesDataModel = StoriesDataModel(st_author_first_name: itemDict["author_first_name"],
                    st_title : itemDict["title"],
                    st_publish_datetime_ago : itemDict["publish_datetime_ago"],
                    st_author_last_name : itemDict["author_last_name"],
                    st_contents_rendered : itemDict["contents_rendered"]
                )
                
                storiesCount++
                refinedStoryItems.append(item)
            }
            
            //save stories count
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(String(storiesCount), forKey: YellrConstants.Keys.StoredStoriesCount)
            defaults.synchronize()
            
        } else {
            
        }

        return refinedStoryItems
    }
    
    func initWebActivityIndicator() {
        self.webActivityIndicator.color = UIColor.lightGrayColor()
        self.webActivityIndicator.startAnimating()
        self.webActivityIndicator.center = self.view.center
        self.view.addSubview(self.webActivityIndicator)
    }
    
    //MARK: Location Delegate functions
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var latestLocation: AnyObject = locations[locations.count - 1]
        
        var latitude : String = String(format: "%.2f", latestLocation.coordinate.latitude)
        var longitude : String = String(format: "%.2f", latestLocation.coordinate.longitude)
        
        //store lat long in prefs
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(latitude, forKey: YellrConstants.Direction.Latitude)
        defaults.setObject(longitude, forKey: YellrConstants.Direction.Longitude)
        defaults.synchronize()        
        
        self.loadStoriesTableView(latitude, longitude: longitude)
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
    
    func applicationBecameActive(notification: NSNotification) {
        var latitude = ""
        var longitude = ""
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let ylatitude = defaults.stringForKey(YellrConstants.Direction.Latitude) {
            latitude = ylatitude
        } else {}
        if let ylongitude = defaults.stringForKey(YellrConstants.Direction.Longitude) {
            longitude = ylongitude
        } else {}
        self.loadStoriesTableView(latitude, longitude: longitude)
        
        Yellr.println("H3")
    }
    
}