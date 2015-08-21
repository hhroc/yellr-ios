//
//  RegexString.swift
//  Yellr
//
//  Created by Debjit Saha on 8/21/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import Foundation

extension String {
    func getMatchesFine (str: String) -> Array<String> {
        var err : NSError?
        let regex = NSRegularExpression(pattern: self, options: NSRegularExpressionOptions(0), error: &err)
        if (err != nil) {
            return Array<String>()
        }
        let nsstr = str as NSString
        let all = NSRange(location: 0, length: nsstr.length)
        var matches : Array<String> = Array<String>()
        regex!.enumerateMatchesInString(str, options: NSMatchingOptions(0), range: all) {
            (result : NSTextCheckingResult!, _, _) in
            matches.append(nsstr.substringWithRange(result.range))
        }
        return matches
    }
}