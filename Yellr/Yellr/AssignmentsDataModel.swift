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
    var as_post_ID : AnyObject?
    var as_question_type_id : AnyObject?
    var answer0 : AnyObject?
    var answer1 : AnyObject?
    var answer2 : AnyObject?
    var answer3 : AnyObject?
    var answer4 : AnyObject?
    var answer5 : AnyObject?
    var answer6 : AnyObject?
    var answer7 : AnyObject?
    var answer8 : AnyObject?
    var answer9 : AnyObject?
    var has_responded : AnyObject?
    
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
    
    var postID:Int {
        get {
            return as_post_ID as! Int
        }
    }
    
    var postType:String {
        get {
            return as_question_type_id as! String
        }
    }
    
    //TODO: Add this property to thi data model
//    var postID:String {
//        get {
//            return as_post_id as! String
//        }
//    }
    
    
    init( var as_question_text : AnyObject?, var as_description : AnyObject?, var as_organization : AnyObject?, var as_post_count : AnyObject?, var as_post_ID : AnyObject?, var as_question_type_id : AnyObject?, var has_responded : AnyObject?, var answer0 : AnyObject?, var answer1 : AnyObject?, var answer2 : AnyObject?, var answer3 : AnyObject?, var answer4 : AnyObject?, var answer5 : AnyObject?, var answer6 : AnyObject?, var answer7 : AnyObject?, var answer8 : AnyObject?, var answer9 : AnyObject?) {
        self.as_question_text = as_question_text
        self.as_description = as_description
        self.as_organization = as_organization
        self.as_post_count = as_post_count
        self.as_post_ID = as_post_ID
        self.as_question_type_id = as_question_type_id
        self.has_responded = has_responded
        self.answer0 = answer0
        self.answer1 = answer1
        self.answer2 = answer2
        self.answer3 = answer3
        self.answer4 = answer4
        self.answer5 = answer5
        self.answer6 = answer6
        self.answer7 = answer7
        self.answer8 = answer8
        self.answer9 = answer9
        super.init();
    }
    
}