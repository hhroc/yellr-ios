//
//  LocalPostDataModel.swift
//  Yellr
//
//  Created by Debjit Saha on 6/5/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import Foundation

class LocalPostDataModel: NSObject {
    
    var lp_last_name : AnyObject?
    var lp_language_code : AnyObject?
    var lp_post_id : AnyObject?
    var lp_verified_user : AnyObject?
    var lp_post_datetime : AnyObject?

    var lp_file_name : AnyObject?
    var lp_media_text : AnyObject?
    var lp_media_type_name : AnyObject?
    var lp_preview_file_name : AnyObject?
    var lp_media_caption : AnyObject?
    
    var lp_first_name : AnyObject?
    var lp_question_text : AnyObject?
    var lp_is_up_vote : AnyObject?
    var lp_down_vote_count : AnyObject?
    var lp_has_voted : AnyObject?
    var lp_language_name : AnyObject?
    var lp_up_vote_count : AnyObject?
    
    init( lp_last_name : AnyObject?, lp_language_code : AnyObject?, lp_post_id : AnyObject?, lp_verified_user : AnyObject?, lp_post_datetime : AnyObject?, lp_file_name : AnyObject?, lp_media_text : AnyObject?, lp_media_type_name : AnyObject?, lp_preview_file_name : AnyObject?, lp_media_caption : AnyObject?, lp_first_name : AnyObject?, lp_question_text : AnyObject?, lp_is_up_vote : AnyObject?, lp_down_vote_count : AnyObject?, lp_has_voted : AnyObject?, lp_language_name : AnyObject?, lp_up_vote_count : AnyObject?) {
        self.lp_last_name = lp_last_name
        self.lp_language_code = lp_language_code
        self.lp_post_id = lp_post_id
        self.lp_verified_user = lp_verified_user
        self.lp_post_datetime = lp_post_datetime
        self.lp_file_name = lp_file_name
        self.lp_media_text = lp_media_text
        self.lp_media_type_name = lp_media_type_name
        self.lp_media_caption = lp_media_caption
        self.lp_preview_file_name = lp_preview_file_name
        self.lp_first_name = lp_first_name
        self.lp_question_text = lp_question_text
        self.lp_is_up_vote = lp_is_up_vote
        self.lp_down_vote_count = lp_down_vote_count
        self.lp_has_voted = lp_has_voted
        self.lp_language_name = lp_language_name
        self.lp_up_vote_count = lp_up_vote_count
        super.init();
    }
    
}