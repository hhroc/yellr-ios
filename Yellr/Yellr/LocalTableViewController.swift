//
//  LocalTableViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 5/29/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit

class LocalTableViewController: UITableViewController {
    
    var data = ["Contrary to popular belief", "Lorem Ipsum is not", "simply random text", "It has roots", "in a piece of", "classical Latin", "literature from", "45 BC, making it", "over 2000 years old", "Richard McClintock", "a Latin professor", "at Hampden-Sydney College", "in Virginia, looked up", "one of the more obscure", "Latin words, consectetur", "from a Lorem Ipsum", "passage, and going", "through the cites", "of the word in", "classical literature", "discovered the", "undoubtable source"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocalTVCIdentifier", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    
}

