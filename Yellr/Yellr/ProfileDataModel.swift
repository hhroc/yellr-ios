//
//  ProfileDataModel.swift
//  Yellr
//
//  Created by Debjit Saha on 6/18/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import Foundation

class ProfileDataModel: NSObject {
    
    var pr_first_name : AnyObject?
    var pr_last_name : AnyObject?
    var pr_verified : AnyObject?
    var pr_success : AnyObject?
    var pr_post_count : AnyObject?
    var pr_post_view_count : AnyObject?
    var pr_organization : AnyObject?
    var pr_post_used_count : AnyObject?
    var pr_email : AnyObject?
    
    //getters
    var fname:String {
        get {
            return pr_first_name as! String
        }
    }
    
    var lname:String {
        get {
            return pr_last_name as! String
        }
    }
    
    var pcount:Int {
        get {
            return pr_post_count as! Int
        }
    }
    
    var pvcount:Int {
        get {
            return pr_post_view_count as! Int
        }
    }
    
    var pucount:Int {
        get {
            return pr_post_used_count as! Int
        }
    }
    
    init(var pr_first_name : AnyObject?,
        var pr_last_name : AnyObject?,
        var pr_verified : AnyObject?,
        var pr_success : AnyObject?,
        var pr_post_count : AnyObject?,
        var pr_post_view_count : AnyObject?,
        var pr_organization : AnyObject?,
        var pr_post_used_count : AnyObject?,
        var pr_email : AnyObject?) {
            self.pr_first_name = pr_first_name
            self.pr_last_name = pr_last_name
            self.pr_verified = pr_verified
            self.pr_success = pr_success
            self.pr_post_count = pr_post_count
            self.pr_post_view_count = pr_post_view_count
            self.pr_organization = pr_organization
            self.pr_post_used_count = pr_post_used_count
            self.pr_email = pr_email
        super.init();
    }
    
}