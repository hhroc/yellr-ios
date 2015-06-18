//
//  ProfileViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 6/15/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileViewController: UIViewController, CLLocationManagerDelegate  {

    @IBOutlet weak var resetCuidButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cuidValue: UILabel!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var verified: UILabel!
    @IBOutlet weak var userLogo: UILabel!
    
    @IBOutlet weak var postsLogo: UILabel!
    @IBOutlet weak var postsViewedLogo: UILabel!
    @IBOutlet weak var postsUsedLogo: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var postsViewedLabel: UILabel!
    @IBOutlet weak var postsUsedLabel: UILabel!
    @IBOutlet weak var postsCount: UILabel!
    @IBOutlet weak var postsViewedCount: UILabel!
    @IBOutlet weak var postsUsedCount: UILabel!
    
    var latitude:String = ""
    var longitude:String = ""
    
    var profileUrlEndpoint: String = ""
    var webActivityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    var urlSession = NSURLSession.sharedSession()
    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString(YellrConstants.Profile.Title, comment: "Profile Screen title")
        self.cancelButton.title =  NSLocalizedString(YellrConstants.Common.BackButton, comment: "Profile Screen back button")
        self.resetCuidButton.title = NSLocalizedString(YellrConstants.Profile.ResetCUIDButton, comment: "Profile Screen Reset CUID button")
        
        self.cuidValue.text = "CUID: " + getCUID()
        
        self.postsLogo.font = UIFont.fontAwesome(size: 14)
        self.postsLogo.text =  "\(String.fontAwesome(unicode: 0xf0e5)) "
        self.postsViewedLogo.font = UIFont.fontAwesome(size: 14)
        self.postsViewedLogo.text =  "\(String.fontAwesome(unicode: 0xf06e)) "
        self.postsUsedLogo.font = UIFont.fontAwesome(size: 14)
        self.postsUsedLogo.text =  "\(String.fontAwesome(unicode: 0xf075)) "
        
        self.verified.font = UIFont.fontAwesome(size: 13)
        self.verified.text =  "\(String.fontAwesome(unicode: 0xf00d))  " + NSLocalizedString(YellrConstants.Profile.Unverified, comment: "Profile Screen Unverified")
        
        self.userLogo.font = UIFont.fontAwesome(size: 44)
        self.userLogo.text =  "\(String.fontAwesome(unicode: 0xf21b)) "
        self.userLogo.backgroundColor = UIColorFromRGB(YellrConstants.Colors.dark_yellow)
        
        self.postsLabel.text = NSLocalizedString(YellrConstants.Profile.PostsLabel, comment: "Profile Screen Posts")
        self.postsViewedLabel.text = NSLocalizedString(YellrConstants.Profile.PostsViewedLabel, comment: "Profile Screen Posts Viewed")
        self.postsUsedLabel.text = NSLocalizedString(YellrConstants.Profile.PostsUsedLabel, comment: "Profile Screen Posts Used")
        
        var resetCuidBarButtonItem:UIBarButtonItem = UIBarButtonItem(fontAwesome: "f084", target: self, action: "resetCuidTapped:")
        self.navigationItem.setRightBarButtonItems([resetCuidBarButtonItem], animated: true)
        
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
    
    //dismiss the profilemodal on pressing cancel
    @IBAction func cancelPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }

    func resetCuidTapped(sender: UIBarButtonItem) {
        let alert = UIAlertView()
        alert.title = NSLocalizedString(YellrConstants.Location.Title, comment: "Location Error Title")
        alert.message = NSLocalizedString(YellrConstants.Location.Message, comment: "Location Error Message")
        alert.addButtonWithTitle(NSLocalizedString(YellrConstants.Location.Okay, comment: "Okay"))
        alert.show()
    }
    
    // MARK: - Networking
    func requestProfile(endPointURL : String, responseHandler : (error : NSError? , items : Array<LocalPostDataModel>?) -> () ) -> () {
        
        let url:NSURL = NSURL(string: endPointURL)!
        let task = self.urlSession.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            
            //yprintln(response)
            //yprintln(error)
            
            if (error == nil) {
                self.profileItems(data)
                responseHandler( error: nil, items: nil)
            } else {
                yprintln(error)
            }
            
        })
        task.resume()
    }
    
    func profileItems(data: NSData) -> Void {
        var jsonParseError: NSError?

        if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonParseError) as? NSDictionary {
            
            //var pr_first_name = jsonResult["first_name"] as! String
            //var pr_last_name = jsonResult["last_name"] as! String
            var pr_verified = jsonResult["verified"] as! Bool
            var pr_success = jsonResult["success"] as! Bool
            var pr_post_count = jsonResult["post_count"] as! Int
            var pr_post_view_count = jsonResult["post_view_count"] as! Int
            var pr_organization = jsonResult["organization"] as! String
            var pr_post_used_count = jsonResult["post_used_count"] as! Int
            //var pr_email = jsonResult["email"] as! String
            
            dispatch_async(dispatch_get_main_queue()!, { () -> Void in
                self.postsCount.text = String(pr_post_count)
                self.postsUsedCount.text = String(pr_post_used_count)
                self.postsViewedCount.text = String(pr_post_view_count)
            })
            
            
        } else {
            
        }

    }
    
    //MARK: Location Delegate functions
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var latestLocation: AnyObject = locations[locations.count - 1]
        
        self.latitude = String(format: "%.2f", latestLocation.coordinate.latitude)
        self.longitude = String(format: "%.2f", latestLocation.coordinate.longitude)
        
        self.profileUrlEndpoint = buildUrl("get_profile.json", self.latitude, self.longitude)
        self.requestProfile(self.profileUrlEndpoint, responseHandler: { (error, items) -> () in
            //TODO: update UI code here
            //yprintln("1")
            
        })
        
        locationManager.stopUpdatingLocation()
        
        //TODO: Store Lat Long in userprefs
        //TODO: stopUpdatingLocation should be called after a couple of seconds from
        //receiving the first location
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        yprintln(error)
        let alert = UIAlertView()
        alert.title = NSLocalizedString(YellrConstants.Location.Title, comment: "Location Error Title")
        alert.message = NSLocalizedString(YellrConstants.Location.Message, comment: "Location Error Message")
        alert.addButtonWithTitle(NSLocalizedString(YellrConstants.Location.Okay, comment: "Okay"))
        alert.show()
    }
    
}