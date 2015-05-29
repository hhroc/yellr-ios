//
//  AssignmentsTableViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 5/29/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit

class AssignmentsTableViewController: UITableViewController {
    
    var data = ["There are many variations", "of passages of Lorem", "Ipsum available, but", "the majority have suffered", "alteration in some form", "by injected humour", "or randomised words", "which don't look even", "slightly believable. If", "you are going to use", "a passage of Lorem Ipsum", "you need to be sure", "there isn't anything", "embarrassing hidden in", "the middle of text", "All the Lorem Ipsum", "generators on the Internet", "tend to repeat predefined", "chunks as necessary"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AssignmentsTVCIdentifier", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    
}