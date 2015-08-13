//
//  VerifyUserViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 8/10/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit
import CoreLocation

class VerifyUserViewController: UIViewController, CLLocationManagerDelegate  {
    
    @IBOutlet weak var screenTitle: UILabel!
    
    var latitude:String = ""
    var longitude:String = ""
    
    @IBOutlet weak var pv_fname: UITextField!
    @IBOutlet weak var pv_lname: UITextField!
    @IBOutlet weak var pv_email: UITextField!
    @IBOutlet weak var pv_pwd: UITextField!
    @IBOutlet weak var pv_uname: UITextField!
    
    var profileUrlEndpoint: String = ""
    var webActivityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    var urlSession = NSURLSession.sharedSession()
    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString(YellrConstants.VerifyProfile.Title, comment: "Verify Profile Screen title")
        
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
    
    //submit button pressed
    @IBAction func submitPressed(sender: UIButton) {
        if (pv_fname != "" && pv_lname != "" && pv_pwd != "" && pv_uname != "") {
            post(["username":pv_uname.text, "password":pv_pwd.text, "first_name":pv_fname.text, "last_name":pv_lname.text, "email":pv_email.text], "verify_user", self.latitude, self.longitude) { (succeeded: Bool, msg: String) -> () in
                Yellr.println("Profile Verification: " + msg)
                
                if (msg != "NOTHING" && msg != "Error") {
                    
                } else {

                }
                
            }
        } else {
            //Show incomplete
        }
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
    
}