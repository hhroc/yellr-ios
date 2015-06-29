//
//  YellrConstants.swift
//  Yellr
//
//  Created by Debjit Saha on 6/1/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import Foundation

struct YellrConstants {
    
    struct AppInfo {
        static let Name = "Yellr"
        static let version = "0.1.8"
        static let DevMode = true
    }
    
    struct Direction {
        static let Longitude = "ylr_longitude"
        static let Latitude = "ylr_latitude"
    }
    
    struct Common {
        static let CancelButton = "cancel_button_text"
        static let BackButton = "back_button_text"
    }
    
    struct TagIds {
        static let AddPostImageView = 221
        static let AddPostVideoView = 222
        static let AddPostAudioView = 223
        static let BottomTabLocal = 1201
        static let BottomTabAssignments = 1202
        static let BottomTabStories = 1203
    }
    
    struct Keys {
        static let StoredStoriesCount = "stored_stories_count_key"
        static let StoredAssignmentsCount = "stored_assignments_count_key"
        static let CUIDKeyName = "ycuid"
        static let RepliedToAssignments = "replied_to_assignments"
    }
    
    struct LocalPosts {
        static let Title = "local_post_title"
        static let AnonymousUser = "anonymous_user"
    }
    
    struct Assignments {
        static let Title = "assignments_title"
    }
    
    struct Stories {
        static let Title = "stories_title"
    }
    
    struct Profile {
        static let Title = "profile_title"
        static let ResetCUIDButton = "profile_reset_cuid_button"
        static let PostsLabel = "profile_posts_label"
        static let PostsViewedLabel = "profile_posts_viewed_label"
        static let PostsUsedLabel = "profile_posts_used_label"
        static let Unverified = "profile_unverified"
        static let ResetDialogTitle = "profile_reset_dialog_title"
        static let ResetDialogMessage = "profile_reset_dialog_message"
        static let ResetDialogConfirm = "profile_reset_dialog_confirm"
    }
    
    struct AddPost {
        static let Title = "new_post_title"
        static let FailMsg = "new_post_failed"
        static let FailMsgEmptyPost = "new_post_failed_empty_text"
        static let FailMsgLocation = "new_post_failed_empty_location"
        static let SuccessMsg = "new_post_success"
        static let PopMenuTitle = "new_post_pop_menu_title"
        static let PopMenuTitleVideo = "new_post_pop_menu_title_video"
        static let PopMenuCamera = "new_post_pop_menu_camera"
        static let PopMenuGallery = "new_post_pop_menu_gallery"
        static let PopMenuCancel = "new_post_pop_menu_cancel"
        
        //first time alert
        static let FirstTimeTitle = "new_post_first_time_alert_title"
        static let FirstTimeMessage = "new_post_first_time_alert_message"
        static let FirstTimeOkay = "new_post_first_time_alert_okay"
        
        //to show the one time screen after free / assgn post
        static let checkVersionOnce = "check_version"
        static let checkVersionOnceAs = "check_version_as"
    }
    
    struct Location {
        static let Title = "location_error_title"
        static let Message = "location_error_message"
        static let Okay = "location_error_okay"
    }
    
    struct API {
        static let endPoint = "https://yellr.net"
        //static let endPoint = "http://yellr.mycodespace.net"
    }
    
    struct ApiMethods {
        static let get = ""
    }
    
    struct Colors {
        static let blue:UInt = 0x2980b9;
        static let dark_blue:UInt = 0x2c3e50;
        static let yellow:UInt = 0xFFD40C;
        static let dark_yellow:UInt = 0xF2BF00;
        static let light_yellow:UInt = 0xFFF22A;
        static let white:UInt = 0xffffff;
        static let black:UInt = 0x2f2f2f;
        static let red:UInt = 0xff6347;
        static let down_vote_red:UInt = 0xff6347;
        static let green:UInt = 0x1abc9c;
        static let up_vote_green:UInt = 0x1abc9c;
        static let grey:UInt = 0x444444;
        static let light_grey:UInt = 0xbbbbbb;
        static let very_light_grey:UInt = 0xe8e8e8;
        static let assignment_response_grey:UInt = 0xe0e0e0;
        static let background:UInt = 0xeeeeee;
    }
}