//
//  YellrTabBarController.swift
//  Yellr
//
//  Created by Debjit Saha on 6/1/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit
import Swift
import CoreLocation

class YellrTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tabBar.barTintColor = UIColor(red:0.12, green:0.15, blue:0.24, alpha:1)
        tabBar.barTintColor = UIColorFromRGB(YellrConstants.Colors.light_grey)
        tabBar.selectedImageTintColor = UIColor.blackColor()
        tabBar.translucent = false
        //tabBar.items
        self.delegate = self
        
        let topSeparator = UIView(frame: CGRectMake(0, 0, tabBar.frame.width, 2))
        topSeparator.backgroundColor = UIColorFromRGB(YellrConstants.Colors.grey)
        
        //tabBar.addSubview(topSeparator)
        
        let item1 = tabBar.items?[0] as! UITabBarItem
        let item2 = tabBar.items?[1] as! UITabBarItem
        let item3 = tabBar.items?[2] as! UITabBarItem
        
        let itemWidth = tabBar.frame.width / 3
        
        //underline yellow bars for tabs
        let selectedBar1 = UIView(frame: CGRectMake(0, tabBar.frame.height+5, itemWidth, 6))
        selectedBar1.tag = 1201
        selectedBar1.hidden = false
        selectedBar1.backgroundColor = UIColorFromRGB(YellrConstants.Colors.yellow)
        
        let selectedBar2 = UIView(frame: CGRectMake(0+itemWidth, tabBar.frame.height+5, itemWidth, 6))
        selectedBar2.tag = 1202
        selectedBar2.hidden = true
        selectedBar2.backgroundColor = UIColorFromRGB(YellrConstants.Colors.yellow)
        
        let selectedBar3 = UIView(frame: CGRectMake(0+2*itemWidth, tabBar.frame.height+5, itemWidth, 6))
        selectedBar3.tag = 1203
        selectedBar3.hidden = true
        selectedBar3.backgroundColor = UIColorFromRGB(YellrConstants.Colors.yellow)
        
        tabBar.addSubview(selectedBar1)
        tabBar.addSubview(selectedBar2)
        tabBar.addSubview(selectedBar3)
        
        //println(tabBarController?.selectedIndex)
        
        for item in tabBar.items as! [UITabBarItem] {
            
            //item.selectedImage = UIImage(named: "ab_transparent_yellr.9.png")
            
            item.setTitleTextAttributes(
                [
                    NSFontAttributeName:UIFont.boldSystemFontOfSize(16),
                    NSForegroundColorAttributeName:UIColor.blackColor()
                ],
                forState: UIControlState.Normal
            )
            
            item.setTitleTextAttributes(
                [
                    NSForegroundColorAttributeName:UIColor.blackColor(),
                    NSBackgroundColorDocumentAttribute:UIColor.blackColor(),
                    NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleThick.rawValue
                ],
                forState: UIControlState.Selected
            )
            
            //sets bottom padding for tab items
            item.setTitlePositionAdjustment(UIOffsetMake(0, -20))
            
            
        }
        
        //left item in tab bar controller nav
        //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(showall)];
        
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Test", style: UIBarButtonItemStyle.Bordered, target: self, action: "test:");
        
//        item.imageInsets = UIEdgeInsetsMake(-6, 0, 6, 0)
//        
//        if item.tag < 1004{
//            let separatorXPosition = (itemWidth * CGFloat(item.tag - 1000)) - CGFloat(0.75)
//            let separatorView = UIView(frame: CGRectMake(separatorXPosition, 0, 1.5, 80))
//            separatorView.backgroundColor = UIColor(red:0.56, green:0.6, blue:0.71, alpha:1)
//            
//            tabBar.insertSubview(separatorView, atIndex: 1)
//        }
        
    }
    
    override func viewWillLayoutSubviews()
    {
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = 60
        tabFrame.origin.y = self.view.frame.size.height - 60
        self.tabBar.frame = tabFrame
    }
    
}