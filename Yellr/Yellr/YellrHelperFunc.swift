//
//  YellrHelperFunc.swift
//  Yellr
//
//  Created by Debjit Saha on 6/1/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import Foundation
import UIKit

let Device = UIDevice.currentDevice()

let iosVersion = NSString(string: Device.systemVersion).doubleValue
let iOS8 = iosVersion >= 8
let iOS7 = iosVersion >= 7 && iosVersion < 8

let debugEnabled:Bool = true

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

/**
 * init nav bar
 */

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

// Append string to NSMutableData
// Shorthand for string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}

/**
 * Post method for uploading Images
 */

func postImage(params : Dictionary<String, String>, image:NSData, latitude:String, longitude:String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
    
    var fieldName: String = "media_file"
    var url: String = buildUrl("upload_media" + ".json", latitude, longitude)
    
    var request = NSMutableURLRequest(URL: NSURL(string: url)!)
    //var request = NSMutableURLRequest(URL: NSURL(string: "http://exa.ms/abc.php")!)
    var session = NSURLSession.sharedSession()
    
    let uniqueId = NSProcessInfo.processInfo().globallyUniqueString
    

    var boundary:String = "Boundary-\(NSUUID().UUIDString)"
    
    request.HTTPMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    let body = NSMutableData()
    
    for (key, value) in params {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
    }
    

    let filePathKey = "media_file"
    let filename = NSUUID().UUIDString + ".jpeg"
    let mimetype = "image/jpeg"
    
    body.appendString("--\(boundary)\r\n")
    body.appendString("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
    body.appendString("Content-Type: \(mimetype)\r\n\r\n")
    body.appendData(image)
    body.appendString("\r\n")
    
    body.appendString("--\(boundary)--\r\n")
    
    
    request.HTTPBody = body
    
    var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in

        var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
        Yellr.println("Body: \(strData)")
        var err: NSError?
        var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
        
        var msg = "NOTHING"
        
        if(err != nil) {
            Yellr.println(err!.localizedDescription)
            let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
            Yellr.println("Error could not parse JSON: '\(jsonStr)'")
            postCompleted(succeeded: false, msg: "Error")
        }
        else {
            if let parseJSON = json {
                // check if successful
                if let success = parseJSON["success"] as? Bool {
                    
                    if (success) {
                        
                        if let mediaId = parseJSON["media_id"] as? String {
                            msg =  mediaId
                        }
                        
                    } else {
                    }
                    postCompleted(succeeded: success, msg: msg)
                }
                return
            }
            else {
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                Yellr.println("Error could not parse JSON: \(jsonStr)")
                postCompleted(succeeded: false, msg: "Error")
            }
        }
    })
    
    task.resume()
    
}

/**
 * Post method for sending API adds
 */
func post(params : Dictionary<String, String>, method : String, latitude:String, longitude:String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
    
    var url: String = buildUrl(method + ".json", latitude, longitude)
    var request = NSMutableURLRequest(URL: NSURL(string: url)!)
    var session = NSURLSession.sharedSession()
    request.HTTPMethod = "POST"
    
    var err: NSError?
    var requestData : String = ""
    
    //build the request data string
    for (key, value) in params {
        requestData += key + "=" + value + "&"
    }
    requestData = dropLast(requestData)
    
    request.HTTPBody = (requestData as NSString).dataUsingEncoding(NSUTF8StringEncoding)
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    //Yellr.println(request)
    
    var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
        //Yellr.println("Response: \(response)")
        var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
        Yellr.println("Body: \(strData)")
        var err: NSError?
        var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
        
        var msg = "NOTHING"
        
        if(err != nil) {
            Yellr.println(err!.localizedDescription)
            let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
            Yellr.println("Error could not parse JSON: '\(jsonStr)'")
            postCompleted(succeeded: false, msg: "Error")
        }
        else {
            if let parseJSON = json {
                // check if successful
                if let success = parseJSON["success"] as? Bool {
                    
                    if (success) {

                        if (method == "publish_post") {
                            if let postId = parseJSON["post_id"] as? Int {
                                msg =  NSString(format:"%d", (stringInterpolationSegment: postId)) as String
                            }
                        } else if (method == "register_vote") {
                            if let voteId = parseJSON["vote_id"] as? Int {
                                msg =  NSString(format:"%d", (stringInterpolationSegment: voteId)) as String
                            }
                            
                        } else if (method == "create_response_message") {
                            
                        } else if (method == "verify_user") {
                            
                        } else if (method == "upload_media") {
                            if let mediaId = parseJSON["media_id"] as? String {
                                msg =  mediaId
                            }
                        }
                        
                    } else {
                    }
                    postCompleted(succeeded: success, msg: msg)
                }
                return
            }
            else {
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                Yellr.println("Error could not parse JSON: \(jsonStr)")
                postCompleted(succeeded: false, msg: "Error")
            }
        }
    })
    
    task.resume()
}

/**
 * generate the API endpoint
 */
func buildUrl(method: String , latitude: String, longitude: String) -> String {
    
    var lang:String = NSLocale.preferredLanguages()[0] as! String
    
    var url = YellrConstants.API.endPoint + "/" + method
    url = url + "?cuid=" + getCUID()
    url = url + "&language_code=" + lang
    
    if (latitude == "NIL" && longitude == "NIL") {
        //rochester
        url = url + "&lat=43.16"
        url = url + "&lng=-77.61"
    } else {
        url = url + "&lat=" + latitude
        url = url + "&lng=" + longitude
    }

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
    let cuidKey = YellrConstants.Keys.CUIDKeyName
    if preferences.objectForKey(cuidKey) == nil {
        cuid = NSUUID().UUIDString.lowercaseString
        preferences.setValue(cuid, forKey: cuidKey)
        //  Save to disk
        let didSave = preferences.synchronize()
        if !didSave {}
    } else {
        cuid = preferences.stringForKey(cuidKey)!.lowercaseString
    }
    return cuid
}

/**
 * reset the CUID
 */
func resetCUID() -> String {
    let preferences = NSUserDefaults.standardUserDefaults()
    var cuid = NSUUID().UUIDString.lowercaseString
    let cuidKey = "ycuid"
    preferences.setValue(cuid, forKey: cuidKey)
    //  Save to disk
    let didSave = preferences.synchronize()
    if !didSave {}
    
    return cuid
}

//function to fetch background data and show notification
func fetchBackgroundDataAndShowNotification() -> Void{
    
    //using sendSynchronousRequest instead of sendAsynchronousRequest
    //as async is not working in background for iOS7
    
    var latitude = "43.16"
    var longitude = "-77.61"
    var storedStoriesCount = 0
    var storiesCount = 0
    var storedAssignmentsCount = 0
    var assignmentsCount = 0
    
    var hasNewStories = false
    var hasNewAssignments = false
    var hasNewStoriesCount = 0
    var hasNewAssignmentsCount = 0
    
    let defaults = NSUserDefaults.standardUserDefaults()
    if let ylatitude = defaults.stringForKey(YellrConstants.Direction.Latitude) {
        latitude = ylatitude
    } else {}
    if let ylongitude = defaults.stringForKey(YellrConstants.Direction.Longitude) {
        longitude = ylongitude
    } else {}
    
    if let ystoredstoriescount = defaults.stringForKey(YellrConstants.Keys.StoredStoriesCount) {
        storedStoriesCount = ystoredstoriescount.toInt()!
        Yellr.println(storedStoriesCount)
    } else {}
    
    if let ystoredassignmentscount = defaults.stringForKey(YellrConstants.Keys.StoredAssignmentsCount) {
        storedAssignmentsCount = ystoredassignmentscount.toInt()!
    } else {}
    
    
    //for iOS7
    //count new stories if any
    
    var request = NSURLRequest(URL: NSURL(string: buildUrl("get_stories.json", latitude, longitude))!);
    
    //NSURLConnection.se
    var response: NSURLResponse?
    var error: NSError?
    
    if let urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error) as NSData? {
        
        if let httpResponse = response as? NSHTTPURLResponse {
            
            
            //Yellr.println()
            
            if let jsonResult = NSJSONSerialization.JSONObjectWithData(urlData, options: .MutableContainers, error: nil) as? NSDictionary {
                
                var rawStoryItems = jsonResult["stories"] as! Array<Dictionary<String,AnyObject>>
                
                for itemDict in rawStoryItems {
                    
                    storiesCount++
                }
                
            } else {
                
            }
            
            if (storiesCount > storedStoriesCount) {
                hasNewStories = true
                hasNewStoriesCount = storiesCount - storedStoriesCount
                
                //store the new stories count in userprefs
                defaults.setObject(String(storiesCount), forKey: YellrConstants.Keys.StoredStoriesCount)
                defaults.synchronize()
            }
            
            
        }
    
    }
    
    //count new assignments if any
    request = NSURLRequest(URL: NSURL(string: buildUrl("get_assignments.json", latitude, longitude))!);
    
    if let urlData = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error) as NSData? {
        
        if let jsonResult = NSJSONSerialization.JSONObjectWithData(urlData, options: nil, error: nil) as? NSDictionary {
            
            var rawAssignmentItems = jsonResult["assignments"] as! Array<Dictionary<String,AnyObject>>
            
            for itemDict in rawAssignmentItems {
                
                assignmentsCount++
            }
            
        } else {
            
        }
        
        if (assignmentsCount > storedAssignmentsCount) {
            hasNewAssignments = true
            hasNewAssignmentsCount = assignmentsCount - storedAssignmentsCount
            
            //store the new assignments count in userprefs
            defaults.setObject(String(assignmentsCount), forKey: YellrConstants.Keys.StoredAssignmentsCount)
            defaults.synchronize()
        }
        
    }
    
    //setup notifications
    var localNotification:UILocalNotification = UILocalNotification()
    var screenToShow = "assignments"
    //localNotification.alertAction = "New notifications on Yellr"
    
    //TODO: Localization
    if (hasNewAssignments && hasNewStories) {
        localNotification.alertBody = "You have new stories and assignments."
    } else if (hasNewAssignments && !hasNewStories) {
        if (hasNewAssignmentsCount > 1) {
            //localNotification.alertBody = "You have \(hasNewAssignmentsCount) new assignments"
            localNotification.alertBody = "You have new assignments to view"
        } else {
            localNotification.alertBody = "You have a new assignment to view"
        }
    } else if (!hasNewAssignments && hasNewStories) {
        if (hasNewAssignmentsCount > 1) {
            localNotification.alertBody = "You have new stories to view"
        } else {
            localNotification.alertBody = "You have a new story to view"
        }
        screenToShow = "stories"
    }
    localNotification.userInfo = ["screen" : screenToShow]
    localNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    
    //for iOS8
    
    //count stories
//    request = NSURLRequest(URL: NSURL(string: buildUrl("get_stories.json", latitude, longitude))!);
//    NSURLConnection.sendAsynchronousRequest(request,queue: NSOperationQueue.mainQueue()) {
//        (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
//        
//        Yellr.println("test2")
//        
//        if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary {
//            
//            var rawStoryItems = jsonResult["stories"] as! Array<Dictionary<String,AnyObject>>
//            
//            for itemDict in rawStoryItems {
//                
//                storiesCount++
//            }
//            
//        } else {
//            
//        }
//        
//        if (storiesCount > storedStoriesCount) {
//            hasNewStories = true
//            hasNewStoriesCount = storiesCount - storedStoriesCount
//        }
//        
//        //count new assignments if any
//        request = NSURLRequest(URL: NSURL(string: buildUrl("get_assignments.json", latitude, longitude))!);
//        
//
//        
//        NSURLConnection.sendAsynchronousRequest(request,queue: NSOperationQueue.mainQueue()) {
//            (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
//            
//            if ((error) != nil) {
//                Yellr.println(error)
//            }
//            
//            Yellr.println("test3")
//            
//            if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary {
//                
//                var rawAssignmentItems = jsonResult["assignments"] as! Array<Dictionary<String,AnyObject>>
//                
//                for itemDict in rawAssignmentItems {
//                    
//                    assignmentsCount++
//                }
//                
//            } else {
//                
//            }
//            
//            if (assignmentsCount > storedAssignmentsCount) {
//                hasNewAssignments = true
//                hasNewAssignmentsCount = assignmentsCount - storedAssignmentsCount
//            }
//            
//            Yellr.println("gegege")
//            
//            //setup notifications
//            var localNotification:UILocalNotification = UILocalNotification()
//            //localNotification.alertAction = "New notifications on Yellr"
//            
//            //TODO: Localization
//            if (hasNewAssignments && hasNewStories) {
//                localNotification.alertBody = "You have new stories and assignments."
//            } else if (hasNewAssignments && !hasNewStories) {
//                if (hasNewAssignmentsCount > 1) {
//                    localNotification.alertBody = "You have \(hasNewAssignmentsCount) new assignment."
//                } else {
//                    localNotification.alertBody = "You have \(hasNewAssignmentsCount) new assignments."
//                }
//            } else if (!hasNewAssignments && hasNewStories) {
//                if (hasNewAssignmentsCount > 1) {
//                    localNotification.alertBody = "You have \(hasNewAssignmentsCount) new story."
//                } else {
//                    localNotification.alertBody = "You have \(hasNewAssignmentsCount) new stories."
//                }
//            }
//            
//            localNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
//            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
//            
//            Yellr.println("Here")
//            
//        }
//        
//    }

}

//init code for the upvote and down vote buttons
func initVoteButtons(downVoteBtn: UIButton, upVoteBtn: UIButton) ->Void {
    downVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.light_grey), forState: .Normal)
    downVoteBtn.setFontAwesome(fontAwesome: "f0dd", forState: .Normal)
    
    downVoteBtn.titleLabel?.textAlignment = .Center
    downVoteBtn.titleLabel?.numberOfLines = 1
    
    upVoteBtn.setTitleColor(UIColorFromRGB(YellrConstants.Colors.light_grey), forState: .Normal)
    upVoteBtn.setFontAwesome(fontAwesome: "f0de", forState: .Normal)
    
    upVoteBtn.titleLabel?.textAlignment = .Center
    upVoteBtn.titleLabel?.numberOfLines = 1
}