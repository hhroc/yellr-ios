//
//  StoriesTableViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 5/29/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit

class StoriesTableViewController: UITableViewController {
    
    var data = ["It is a long established", "fact that a reader", "will be distracted", "by the readable content", "of a page when looking", "at its layout. The point", "of using Lorem Ipsum", "is that it has", "a more-or-less normal", "distribution of letters", "as opposed to using", "'Content here, content here'", "making it look like", "readable English", "Many desktop publishing", "packages and web page", "editors now use Lorem", "Ipsum as their default", "model text", "and a search"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StoriesTVCIdentifier", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    
}