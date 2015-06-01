//
//  StoryDetailViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 6/1/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import Foundation
import UIKit

class StoryDetailViewController: UIViewController {
    var story: String!
    
    @IBOutlet weak var myWebView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(story)
        let url = NSURL (string: story);
        let requestObj = NSURLRequest(URL: url!);
        myWebView.loadRequest(requestObj);
        
    }
}