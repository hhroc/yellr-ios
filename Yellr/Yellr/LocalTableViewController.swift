//
//  LocalTableViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 5/29/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit

class LocalTableViewController: UITableViewController {
    
    //This will be replaced by an actual data source
    //from the API response
    var data = ["Contrary to popular belief", "Lorem Ipsum is not", "simply random text", "It has roots", "in a piece of", "classical Latin", "literature from", "45 BC, making it", "over 2000 years old", "Richard McClintock", "a Latin professor", "at Hampden-Sydney College", "in Virginia, looked up", "one of the more obscure", "Latin words, consectetur", "from a Lorem Ipsum", "passage, and going", "through the cites", "of the word in", "classical literature", "discovered the", "undoubtable source"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Determine the number of rows to show
    //in the tableview
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    //Update the cell object to show labels
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocalTVCIdentifier", forIndexPath: indexPath) as! LocalTableViewCell
        //cell.textLabel?.text = data[indexPath.row]
        cell.postTitle?.text = data[indexPath.row]
        cell.postedBy?.text = "Anonymous"
        cell.postedOn?.text = "\((indexPath.row + 1) * 3)m ago"
        cell.upVoteCount?.text = "\((indexPath.row + 1) * 5)"
        cell.downVoteCount?.text = "-\((indexPath.row + 1) * 3)"
        cell.mediaContainer?.hidden = true
        
        return cell
    }
    
    
}

