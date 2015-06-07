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
    var lname: String!
    var fname: String!
    var publishedOn: String!
    var content: String!
    
    @IBOutlet weak var stitle: UILabel!
    @IBOutlet weak var myWebView: UIWebView!
    @IBOutlet weak var postedBy: UILabel!
    @IBOutlet weak var postedOn: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stitle.text = story
        postedBy.text = lname + " " + fname
        postedOn.text = publishedOn
        myWebView.loadHTMLString(content, baseURL: nil)
        
    }
}