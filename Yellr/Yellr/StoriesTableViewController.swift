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
    
    var assignmentsUrlEndpoint: String = ""
    var dataSource : Array<StoriesDataModel> = []
    var webActivityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    var urlSession = NSURLSession.sharedSession()
    var selectedStory: String!
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString(YellrConstants.Stories.Title, comment: "Stories Screen title")
        self.initWebActivityIndicator()
        //self.loadStoriesTableView()
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let subViews = self.tabBarController!.tabBar.subviews
        for subview in subViews{
            if (subview.tag == 1201) {
                (subview as? UIView)!.hidden = true
            } else if (subview.tag == 1202) {
                (subview as? UIView)!.hidden = true
            } else if (subview.tag == 1203) {
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
    
    //starts the tableviewload process
    //api call and then populate
    func loadStoriesTableView(latitude : String, longitude : String) {
        
        self.assignmentsUrlEndpoint = buildUrl("get_stories.json", latitude, longitude)
        self.requestStories(self.assignmentsUrlEndpoint, responseHandler: { (error, items) -> () in
            //TODO: update UI code here
            //debugPrint("1")
            
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
            
            self.dataSource = self.storyItems(data)
            
            dispatch_async(dispatch_get_main_queue()!, { () -> Void in
                self.tableView.reloadData()
                self.webActivityIndicator.hidden = true
            })
            
            responseHandler( error: nil, items: nil)
        })
        task.resume()
    }
    
    func storyItems(data: NSData) -> (Array<StoriesDataModel>) {
        var jsonParseError: NSError?
        var refinedStoryItems : Array<StoriesDataModel> = []
        
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonParseError) as? NSDictionary {

            var rawStoryItems = jsonResult["stories"] as! Array<Dictionary<String,AnyObject>>
            
            for itemDict in rawStoryItems {
                
                var item : StoriesDataModel = StoriesDataModel(st_author_first_name: itemDict["author_first_name"],
                    st_title : itemDict["title"],
                    st_publish_datetime_ago : itemDict["publish_datetime_ago"],
                    st_author_last_name : itemDict["author_last_name"],
                    st_contents_rendered : itemDict["contents_rendered"]
                )
                
                refinedStoryItems.append(item)
            }
            
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
        
        self.loadStoriesTableView(latitude, longitude: longitude)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        debugPrint(error)
        let alert = UIAlertView()
        alert.title = NSLocalizedString(YellrConstants.Location.Title, comment: "Location Error Title")
        alert.message = NSLocalizedString(YellrConstants.Location.Message, comment: "Location Error Message")
        alert.addButtonWithTitle(NSLocalizedString(YellrConstants.Location.Okay, comment: "Okay"))
        alert.show()
    }
    
}