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
    
    init( var as_question_text : AnyObject?, var as_description : AnyObject?, var as_organization : AnyObject?, var as_post_count : AnyObject?) {
        self.as_question_text = as_question_text
        self.as_description = as_description
        self.as_organization = as_organization
        self.as_post_count = as_post_count
        super.init();
    }
    
}