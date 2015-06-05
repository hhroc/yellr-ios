//
//  LocalTableViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 5/29/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit

class LocalTableViewController: UITableViewController {
    
    let localViewModel = LocalViewModel()
    
    var data = ["Contrary to popular belief", "Lorem Ipsum is not", "simply random text", "It has roots", "in a piece of", "classical Latin", "literature from", "45 BC, making it", "over 2000 years old", "Richard McClintock", "a Latin professor", "at Hampden-Sydney College", "in Virginia, looked up", "one of the more obscure", "Latin words, consectetur", "from a Lorem Ipsum", "passage, and going", "through the cites", "of the word in", "classical literature", "discovered the", "undoubtable source"]
    
    var localPostsUrlEndpoint: String = buildUrl("get_local_posts.json")
    var dataSource : Array<LocalPostDataModel> = []
    var webActivityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    var urlSession = NSURLSession.sharedSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString(YellrConstants.LocalPosts.Title, comment: "Local Post Screen title")
        initWebActivityIndicator()
        self.requestLocalPosts(self.localPostsUrlEndpoint, responseHandler: { (error, items) -> () in
            // present processed url session response results to the user –- update UI code //
        })

    }
    
    //We need sections in order to load the 
    //newly fetched data in the table view 
    //(data that is fetched on pulldown or new refresh)
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return localViewModel.numberOfSections()
    }
    
    //Determine the number of rows to show
    //in the tableview
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return localViewModel.numberOfRowsInSection(section)
        return self.dataSource.count
    }
    
    //Update the cell object to show labels
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocalTVCIdentifier", forIndexPath: indexPath) as! LocalTableViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell:LocalTableViewCell, atIndexPath indexPath:NSIndexPath) {
        //cell.textLabel?.text = data[indexPath.row]
        var localPostItem : LocalPostDataModel = self.dataSource[indexPath.row]
        //cell.textLabel.text = supplyItem.bsn_name;
        
        cell.postTitle?.text = localPostItem.lp_question_text as? String
        cell.postedBy?.text = localPostItem.lp_first_name as? String
        cell.postedOn?.text = localPostItem.lp_post_datetime as? String
        cell.upVoteCount?.text = localPostItem.lp_up_vote_count as? String
        cell.downVoteCount?.text = localPostItem.lp_down_vote_count as? String
        cell.mediaContainer?.hidden = true
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    }
    
    func initWebActivityIndicator() {
        self.webActivityIndicator.color = UIColor.lightGrayColor()
        self.webActivityIndicator.startAnimating()
        self.webActivityIndicator.center = self.view.center
        self.view.addSubview(self.webActivityIndicator)
    }
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 60.0
//    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//    }
    
    // MARK: - Networking
    func requestLocalPosts(endPointURL : String, responseHandler : (error : NSError? , items : Array<LocalPostDataModel>?) -> () ) -> () {
        let url:NSURL = NSURL(string: endPointURL)!
        let task = self.urlSession.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            
            //println(response)
            self.dataSource = self.localPostItems(data)
            
            dispatch_async(dispatch_get_main_queue()!, { () -> Void in
                self.tableView.reloadData()
                self.webActivityIndicator.hidden = true
            })
            
            responseHandler( error: nil, items: nil)
        })
        task.resume()
    }
    
    func localPostItems(data: NSData) -> (Array<LocalPostDataModel>) {
        var jsonParseError: NSError?
        var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonParseError) as! NSDictionary

        var rawLocalPostItems = jsonResult["posts"] as! Array<Dictionary<String,AnyObject>>
        var refinedLocalPostItems : Array<LocalPostDataModel> = []
        for itemDict in rawLocalPostItems {
            var item : LocalPostDataModel = LocalPostDataModel(lp_last_name: itemDict["last_name"],
                lp_language_code : itemDict["last_name"],
                lp_post_id : itemDict["post_id"],
                lp_verified_user : itemDict["verified_user"],
                lp_post_datetime : itemDict["post_datetime"],
                lp_media_objects : "", //itemDict["media_objects"],
                lp_first_name : itemDict["first_name"],
                lp_question_text : itemDict["question_text"],
                lp_is_up_vote : itemDict["is_up_vote"],
                lp_down_vote_count : itemDict["down_vote_count"],
                lp_has_voted : itemDict["has_voted"],
                lp_language_name : itemDict["language_name"],
                lp_up_vote_count : itemDict["up_vote_count"] )
            refinedLocalPostItems.append(item)
            //println(itemDict)
        }
        return refinedLocalPostItems
    }
    
    
}

