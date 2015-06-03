//
//  StoriesTableViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 5/29/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit

class StoriesTableViewController: UITableViewController {
    
    var data = ["google.com", "http://www.facebook.com", "http://www.yahoo.com", "http://www.rit.edu", "http://www.About.com", "http://www.Bartleby.com", "http://www.Download.com", "http://www.Craigslist.org", "http://www.Reference.com", "http://www.Wikipedia.org", "http://www.Beliefnet.com", "http://www.Weather.com", "http://www.Search.com", "http://www.Hotmail.com", "http://www.NIH.gov", "http://www.CNET.com", "http://www.Refdesk.com", "http://www.MayoClinic.com", "http://www.GuideStar.org", "http://www.FirstGov.gov", "http://www.BBC.com", "http://www.IMDB.com", "http://www.Expedia.com", "http://www.Slate.com", "http://www.Nutrition.gov", "http://www.Altmedicine.com", "http://www.Citysearch.com", "http://www.Monster.com", "http://www.Vote-Smart.org", "http://www.Sciam.com", "http://www.ESPN.com", "http://www.Encarta.com", "http://www.Findlaw.com", "http://www.Nature.com", "http://www.Time.com"]
    
    var selectedStory: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString(YellrConstants.Stories.Title, comment: "Stories Screen title")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StoriesTVCIdentifier", forIndexPath: indexPath) as! StoriesTableViewCell
        cell.story?.text = data[indexPath.row]
        cell.postedBy?.text = "Anonymous"
        cell.postedOn?.text = "\((indexPath.row + 1) * 2)h"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if (segue.identifier == "StoryDetailSegue") {
            
            var indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow()!
            var dataToSend:NSString = self.data[indexPath.row] as String
            
            //initialise the destination VC
            var viewController = segue.destinationViewController as! StoryDetailViewController
            // pass in the value to be sent
            viewController.story = dataToSend as String;
        }
    }
    
    
}