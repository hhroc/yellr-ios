//
//  AssignmentsDataModel.swift
//  Yellr
//
//  Created by Debjit Saha on 6/7/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import Foundation

class AssignmentsDataModel: NSObject {
    
    var as_question_text : AnyObject?
    var as_description : AnyObject?
    var as_organization : AnyObject?
    var as_post_count : AnyObject?
    
    //getters
    var postTitle:String {
        get {
            return as_question_text as! String
        }
    }
    
    var postDesc:String {
        get {
            return as_description as! String
        }
    }
    
    //TODO: Add this property to thi data model
//    var postID:String {
//        get {
//            return as_post_id as! String
//        }
//    }
    
    
    init( var as_question_text : AnyObject?, var as_description : AnyObject?, var as_organization : AnyObject?, var as_post_count : AnyObject?) {
        self.as_question_text = as_question_text
        self.as_description = as_description
        self.as_organization = as_organization
        self.as_post_count = as_post_count
        super.init();
    }
    
}