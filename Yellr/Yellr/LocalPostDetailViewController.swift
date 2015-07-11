//
//  LocalPostDetailViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 6/10/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import Foundation
import UIKit

class LocalPostDetailViewController: UIViewController {
    
    var story: String!
    var lname: String!
    var fname: String!
    var publishedOn: String!
    var content: String!

    @IBOutlet weak var postedBy: UILabel!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postedOn: UILabel!
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var upVoteCount: UILabel!
    @IBOutlet weak var downVoteCount: UILabel!
    
    @IBOutlet weak var upVoteBtn: UIButton!
    @IBOutlet weak var downVoteBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVoteButtons(downVoteBtn, upVoteBtn)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)

    }
}