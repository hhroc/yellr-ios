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
        static let version = "0.1"
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
    }
    
    struct AddPost {
        static let Title = "new_post_title"
        static let FailMsg = "new_post_failed"
        static let SuccessMsg = "new_post_success"
        //to show the one time screen after free / assgn post
        static let checkVersionOnce = "check_version"
        static let checkVersionOnceAs = "check_version_as"
    }
    
    struct API {
        //static let endPoint = "https://yellr.net"
        static let endPoint = "http://yellr.mycodespace.net"
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
        static let assignment_response_grey:UInt = 0xe0e0e0;
        static let background:UInt = 0xeeeeee;
    }
}