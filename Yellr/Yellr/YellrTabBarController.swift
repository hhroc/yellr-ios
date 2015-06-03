//
//  YellrTabBarController.swift
//  Yellr
//
//  Created by Debjit Saha on 6/1/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit
import Swift

class YellrTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tabBar.barTintColor = UIColor(red:0.12, green:0.15, blue:0.24, alpha:1)
        tabBar.barTintColor = UIColorFromRGB(YellrConstants.Colors.grey)
        tabBar.selectedImageTintColor = UIColor.whiteColor()
        tabBar.translucent = false
        self.delegate = self
        
        let topSeparator = UIView(frame: CGRectMake(0, 0, tabBar.frame.width, 2))
        topSeparator.backgroundColor = UIColor(red:0.15, green:0.67, blue:0.65, alpha:1)
        
        tabBar.addSubview(topSeparator)
        
        let item1 = tabBar.items?[0] as! UITabBarItem
        let item2 = tabBar.items?[1] as! UITabBarItem
        let item3 = tabBar.items?[2] as! UITabBarItem
        
        let itemWidth = tabBar.frame.width / 3
        
        for item in tabBar.items as! [UITabBarItem] {
            item.setTitleTextAttributes(
                [
                    NSFontAttributeName:UIFont.boldSystemFontOfSize(16),
                    NSForegroundColorAttributeName:UIColor.whiteColor()
                ],
                forState: UIControlState.Normal
            )
            
            item.setTitleTextAttributes(
                [
                    NSForegroundColorAttributeName:UIColorFromRGB(YellrConstants.Colors.yellow),
                    NSBackgroundColorDocumentAttribute:UIColor.blackColor()
                ],
                forState: UIControlState.Selected
            )
            
            //sets bottom padding for tab items
            item.setTitlePositionAdjustment(UIOffsetMake(0, -20))
            
            item.imageInsets = UIEdgeInsetsMake(-6, 0, 6, 0)
            
            if item.tag < 1004{
                let separatorXPosition = (itemWidth * CGFloat(item.tag - 1000)) - CGFloat(0.75)
                let separatorView = UIView(frame: CGRectMake(separatorXPosition, 0, 1.5, 80))
                separatorView.backgroundColor = UIColor(red:0.56, green:0.6, blue:0.71, alpha:1)
                
                tabBar.insertSubview(separatorView, atIndex: 1)
            }
            
        }
        
        //left item in tab bar controller nav
        //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(showall)];
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Test", style: UIBarButtonItemStyle.Bordered, target: self, action: "test:");
        
    }
    
    func test() {
        println("test")
    }
    
    override func viewWillLayoutSubviews()
    {
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = 60
        tabFrame.origin.y = self.view.frame.size.height - 60
        self.tabBar.frame = tabFrame
    }
    
}