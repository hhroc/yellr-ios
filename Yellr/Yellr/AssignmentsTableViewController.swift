//
//  AssignmentsTableViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 5/29/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit
import CoreLocation

class AssignmentsTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    let assgnViewModel = AssignmentsViewModel()
    
    var repliedToAssignments : NSString = ""
    var assignmentsUrlEndpoint: String = ""
    var dataSource : Array<AssignmentsDataModel> = []
    var webActivityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    var urlSession = NSURLSession.sharedSession()
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webActivityIndicator.hidden = true
        self.title = NSLocalizedString(YellrConstants.Assignments.Title, comment: "Assignments Screen title")
        
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let subViews = self.tabBarController!.tabBar.subviews
        for subview in subViews{
            if (subview.tag == YellrConstants.TagIds.BottomTabLocal) {
                (subview as? UIView)!.hidden = true
            } else if (subview.tag == YellrConstants.TagIds.BottomTabAssignments) {
                (subview as? UIView)!.hidden = false
            } else if (subview.tag == YellrConstants.TagIds.BottomTabStories) {
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
        
        //get replied to assignments
        let asdefaults = NSUserDefaults.standardUserDefaults()
        if asdefaults.objectForKey(YellrConstants.Keys.RepliedToAssignments) == nil {
            
        } else {
            self.repliedToAssignments = asdefaults.stringForKey(YellrConstants.Keys.RepliedToAssignments)!
        }
        Yellr.println(self.repliedToAssignments)

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AssignmentsTVCIdentifier", forIndexPath: indexPath) as! AssignmentsTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if (segue.identifier == "AssignmentDetail") {
            
            var indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow()!
            
            //silly mistake that I was making- http://stackoverflow.com/questions/28573635/
            let nav = segue.destinationViewController as! UINavigationController
            let addPostViewController = nav.topViewController as! AddPostViewController
            
            addPostViewController.postTitle = self.dataSource[indexPath.row].postTitle;
            addPostViewController.postDesc = self.dataSource[indexPath.row].postDesc;
            addPostViewController.asgPost = "Yes";
            addPostViewController.postId = self.dataSource[indexPath.row].postID;
            //addPostViewController.postAssignmentID = self.dataSource[indexPath.row].postID;
            
        }
    }
    
    //when profile button is tapped in UINavBar
    func profileTapped(sender:UIButton) {
        self.performSegueWithIdentifier("AssignmentToProfile", sender: self)
    }
    
    //when add post button is tapped in UINavBar
    func addPostTapped(sender:UIButton) {
        self.performSegueWithIdentifier("AssignmentToPost", sender: self)
    }
    
    //starts the tableviewload process
    //api call and then populate
    func loadAssignmentsTableView(latitude : String, longitude : String) {
        
        self.initWebActivityIndicator()
        
        self.assignmentsUrlEndpoint = buildUrl("get_assignments.json", latitude, longitude)
        self.requestAssignments(self.assignmentsUrlEndpoint, responseHandler: { (error, items) -> () in
            
            self.dataSource = items!
            
            dispatch_async(dispatch_get_main_queue()!, { () -> Void in
                self.tableView.reloadData()
                self.webActivityIndicator.hidden = true
            })
            
        })
    }

    func configureCell(cell:AssignmentsTableViewCell, atIndexPath indexPath:NSIndexPath) {
        
        var assignmentItem : AssignmentsDataModel = self.dataSource[indexPath.row]
        var postID = assignmentItem.as_post_ID as? Int
        
        if (iOS8) {
            if (self.repliedToAssignments.containsString("[" + String(stringInterpolationSegment: postID!) + "]")) {
                cell.backgroundColor = UIColorFromRGB(YellrConstants.Colors.very_light_grey)
            }
        } else {
            //for ios7
            var range : NSRange = self.repliedToAssignments.rangeOfString("[" + String(stringInterpolationSegment: postID!) + "]")
            if (range.length != 0) {
                cell.backgroundColor = UIColorFromRGB(YellrConstants.Colors.very_light_grey)
            }
        }

        
        cell.assgnTitle.text = assignmentItem.as_question_text as? String
        
        var postedBy:String = (assignmentItem.as_organization as? String)!
        cell.postedBy?.font = UIFont.fontAwesome(size: 13)
        cell.postedBy?.text =  "\(String.fontAwesome(unicode: 0xf007)) " + postedBy
        
        //number of comments - variable name is bad, i know
        var postedOn:String = NSString(format:"%d", (stringInterpolationSegment: (assignmentItem.as_post_count as? Int)!)) as String
        cell.postedOn?.font = UIFont.fontAwesome(size: 13)
        cell.postedOn?.text =  "\(String.fontAwesome(unicode: 0xf086)) " + postedOn
        
    }
    
    // MARK: - Networking
    func requestAssignments(endPointURL : String, responseHandler : (error : NSError? , items : Array<AssignmentsDataModel>?) -> () ) -> () {

        let url:NSURL = NSURL(string: endPointURL)!
        let task = self.urlSession.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            
            responseHandler( error: nil, items: self.assignmentItems(data))
        })
        task.resume()
    }
    
    func assignmentItems(data: NSData) -> (Array<AssignmentsDataModel>) {
        var jsonParseError: NSError?
        var refinedAssignmentItems : Array<AssignmentsDataModel> = []
        var assignmentsCount = 0
        
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonParseError) as? NSDictionary {
         
            var rawAssignmentItems = jsonResult["assignments"] as! Array<Dictionary<String,AnyObject>>
            
            
            for itemDict in rawAssignmentItems {
                
                var item : AssignmentsDataModel = AssignmentsDataModel(as_question_text: itemDict["question_text"],
                    as_description : itemDict["description"],
                    as_organization : itemDict["organization"],
                    as_post_count : itemDict["post_count"],
                    as_post_ID : itemDict["assignment_id"])
                
                assignmentsCount++
                refinedAssignmentItems.append(item)
            }
            
            //save assignments count
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(String(assignmentsCount), forKey: YellrConstants.Keys.StoredStoriesCount)
            defaults.synchronize()
            
        } else {
            
        }
        return refinedAssignmentItems
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
        
        self.loadAssignmentsTableView(latitude, longitude: longitude)
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
    
}