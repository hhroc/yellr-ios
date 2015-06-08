//
//  StoriesDataModel.swift
//  Yellr
//
//  Created by Debjit Saha on 6/7/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import Foundation

class StoriesDataModel: NSObject {
    
    var st_author_first_name : AnyObject?
    var st_title : AnyObject?
    var st_publish_datetime_ago : AnyObject?
    var st_author_last_name : AnyObject?
    var st_contents_rendered : AnyObject?
    
    //getters
    var fname:String {
        get {
            return st_author_first_name as! String
        }
    }
    
    var lname:String {
        get {
            return st_author_last_name as! String
        }
    }
    
    var stitle:String {
        get {
            return st_title as! String
        }
    }
    
    var publish:String {
        get {
            return st_publish_datetime_ago as! String
        }
    }
    
    var content:String {
        get {
            return st_contents_rendered as! String
        }
    }
    
    init(var st_author_first_name : AnyObject?, var st_title : AnyObject?, var st_publish_datetime_ago : AnyObject?, var st_author_last_name : AnyObject?, var st_contents_rendered : AnyObject?) {
        self.st_author_first_name = st_author_first_name
        self.st_title = st_title
        self.st_publish_datetime_ago = st_publish_datetime_ago
        self.st_author_last_name = st_author_last_name
        self.st_contents_rendered = st_contents_rendered
        super.init();
    }
    
}