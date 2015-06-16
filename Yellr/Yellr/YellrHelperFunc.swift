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
 * Debug Function
 */
func yprintln(input: AnyObject) {
    if (debugEnabled) {
        println(input)
    }
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
 * Post method for uploading Images
 */

func postImage(params : Dictionary<String, String>, image:NSData, postCompleted : (succeeded: Bool, msg: String) -> ()) {
    
    var fieldName: String = "media_file"
    var url: String = buildUrl("upload_media" + ".json", "NIL", "NIL")
    
    var request = NSMutableURLRequest(URL: NSURL(string: url)!)
    //var request = NSMutableURLRequest(URL: NSURL(string: "http://exa.ms/abc.php")!)
    var session = NSURLSession.sharedSession()
    
    let uniqueId = NSProcessInfo.processInfo().globallyUniqueString
    
    var postBody:NSMutableData = NSMutableData()
    var postData:String = String()
    var boundary:String = "------WebKitFormBoundary\(uniqueId)"
    
    request.HTTPMethod = "POST"
    
    request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField:"Content-Type")
    
    //add the caption text
    postData += "--\(boundary)\r\n"
    for (key, value : String) in params {
        postData += "--\(boundary)\r\n"
        postData += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
        postData += "\(value)\r\n"
    }
    
    //add the image file
    postData += "--\(boundary)\r\n"
    postData += "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(Int64(NSDate().timeIntervalSince1970*1000)).jpg\"\r\n"
    postData += "Content-Type: image/jpeg\r\n\r\n"
    postBody.appendData(postData.dataUsingEncoding(NSUTF8StringEncoding)!)
    postBody.appendData(image)
    
    postData = String()
    postData += "\r\n"
    postData += "\r\n--\(boundary)--\r\n"
    
    postBody.appendData(postData.dataUsingEncoding(NSUTF8StringEncoding)!)
    
    request.HTTPBody = NSData(data: postBody)
    
    var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
        //yprintln("Response: \(response)")
        var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
        yprintln("Body: \(strData)")
        var err: NSError?
        var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
        
        var msg = "NOTHING"
        
        if(err != nil) {
            yprintln(err!.localizedDescription)
            let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
            yprintln("Error could not parse JSON: '\(jsonStr)'")
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
                yprintln("Error could not parse JSON: \(jsonStr)")
                postCompleted(succeeded: false, msg: "Error")
            }
        }
    })
    
    task.resume()
    
}

/**
 * Post method for sending API adds
 */
func post(params : Dictionary<String, String>, method : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
    
    var url: String = buildUrl(method + ".json", "NIL", "NIL")
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
    
    //yprintln(request)
    
    var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
        //yprintln("Response: \(response)")
        var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
        yprintln("Body: \(strData)")
        var err: NSError?
        var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
        
        var msg = "NOTHING"
        
        if(err != nil) {
            yprintln(err!.localizedDescription)
            let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
            yprintln("Error could not parse JSON: '\(jsonStr)'")
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
                yprintln("Error could not parse JSON: \(jsonStr)")
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