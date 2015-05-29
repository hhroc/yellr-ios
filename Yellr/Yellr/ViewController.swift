//
//  ViewController.swift
//  Yellr
//
//  Created by Debjit Saha on 5/26/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var view1: UITableView!
    @IBOutlet weak var view2: UITableView!
    @IBOutlet weak var view3: UITableView!

    @IBOutlet weak var topTab: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view2.hidden = true;
        self.view3.hidden = true;
        self.topTab.setEnabled(true, forSegmentAtIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tabSelected(sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0) {
            self.view1.hidden = false;
            self.view2.hidden = true;
            self.view3.hidden = true;
        } else if (sender.selectedSegmentIndex == 1) {
            self.view1.hidden = true;
            self.view2.hidden = false;
            self.view3.hidden = true;
        } else if (sender.selectedSegmentIndex == 2) {
            self.view1.hidden = true;
            self.view2.hidden = true;
            self.view3.hidden = false;
        }
    }
    

}

