//
//  YellrHelperFunc.swift
//  Yellr
//
//  Created by Debjit Saha on 6/1/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import Foundation
import UIKit

/**
 * create UIColor object from HExvalues
 */
func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

func initNavBarStyle() {
    //Nav bar color
    UINavigationBar.appearance().barTintColor = UIColorFromRGB(YellrConstants.Colors.yellow)
    UINavigationBar.appearance().tintColor = UIColor.blackColor()
    
    //UINavbar title font
    //UINavigationBar.appearance().titleTextAttributes = [ NSFontAttributeName: UIFont(name: "IowanOldStyle", size: 20)!]
    
    //tab bar colors and styles
    //UITabBar.appearance().barTintColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
    //UITabBar.appearance().translucent = false
    
    //set the color for selected & unselected states
    //UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Normal)
    //UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor()], forState:.Selected)
    
    //set image for selected tab
    //UITabBar.appearance().selectionIndicatorImage = UIImage(named: "Selected.png")
    
    //UITabBarItem.setTitlePositionAdjustment()
    
    //tabBarItem.titlePositionAdjustment = UIOffsetMake(-15, 0);

    //UITabBar.appearance().selectedImageTintColor = UIColor.blackColor()
    
    //UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName:UIFont(name: "American Typewriter", size: 20)], forState:.Normal)
//    UITabBarItem.appearance().setTitleTextAttributes(
//        [NSFontAttributeName: UIFont(name:"Ubuntu", size:11),
//            NSForegroundColorAttributeName: UIColor(rgb: 0x929292)],
//        forState: .Normal)
    
}

/**
 * Post method for sending API adds
 */
func post(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
    var request = NSMutableURLRequest(URL: NSURL(string: url)!)
    var session = NSURLSession.sharedSession()
    request.HTTPMethod = "POST"
    
    var err: NSError?
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
        println("Response: \(response)")
        var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
        println("Body: \(strData)")
        var err: NSError?
        var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
        
        var msg = "No message"
        
        // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
        if(err != nil) {
            println(err!.localizedDescription)
            let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Error could not parse JSON: '\(jsonStr)'")
            postCompleted(succeeded: false, msg: "Error")
        }
        else {
            // The JSONObjectWithData constructor didn't return an error. But, we should still
            // check and make sure that json has a value using optional binding.
            if let parseJSON = json {
                // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                if let success = parseJSON["success"] as? Bool {
                    println("Succes: \(success)")
                    postCompleted(succeeded: success, msg: "Logged in.")
                }
                return
            }
            else {
                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: \(jsonStr)")
                postCompleted(succeeded: false, msg: "Error")
            }
        }
    })
    
    task.resume()
}

/**
 * generate the API endpoint
 */
func buildUrl(method: String ) -> String {
    
    let lat:Double = 43.161030000000000000
    let long:Double = -77.610921900000000000
    var lang:String = NSLocale.preferredLanguages()[0] as! String
        
    var url = YellrConstants.API.endPoint + "/" + method
    url = url + "?cuid=" + getCUID()
    url = url + "&language_code=" + lang
    url = url + "&lat=" + String(format:"%f", lat)
    url = url + "&lng=" + String(format:"%f", long)
    url = url + "&platform=" + "iOS"
    url = url + "&app_version=" + YellrConstants.AppInfo.version
    
    return url;
}

/**
 * return the CUID
 */
func getCUID() -> String {
    let preferences = NSUserDefaults.standardUserDefaults()
    var cuid = ""
    let cuidKey = "ycuid"
    if preferences.objectForKey(cuidKey) == nil {
        cuid = NSUUID().UUIDString
        preferences.setValue(cuid, forKey: cuidKey)
        //  Save to disk
        let didSave = preferences.synchronize()
        if !didSave {}
    } else {
        cuid = preferences.stringForKey(cuidKey)!
    }
    return cuid
}

/**
 * reset the CUID
 */
func resetCUID() {
    let preferences = NSUserDefaults.standardUserDefaults()
    var cuid = NSUUID().UUIDString
    let cuidKey = "ycuid"
    preferences.setValue(cuid, forKey: cuidKey)
    //  Save to disk
    let didSave = preferences.synchronize()
    if !didSave {}
}