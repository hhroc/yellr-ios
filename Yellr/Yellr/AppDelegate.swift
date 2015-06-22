//
//  AppDelegate.swift
//  Yellr
//
//  Created by Debjit Saha on 5/29/15.
//  Copyright (c) 2015 wxxi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //nav bar customisation
        initNavBarStyle()
        
        //local notifications
        if (iOS8) {
            let settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        } else {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(UIRemoteNotificationType.Alert | UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert)
        }
//        if (iOS8) {
//            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil))
//        }
        
        return true
    }
    
    //needed to start the background service for checking new assignment / story data
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        Yellr.println("Background Data")
        completionHandler(UIBackgroundFetchResult.NewData)
        fetchBackgroundDataAndShowNotification()
    }
    
    //to take care of stuff after the app becomes active from local notify / or not
    //for iOS7
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        Yellr.println("thisihs1")
        
        if (application.applicationState == UIApplicationState.Inactive ) {
            //The application received the notification from an inactive state, i.e. the user tapped the "View" button for the alert.
            //If the visible view controller in your view controller stack isn't the one you need then show the right one.
            Yellr.println("thisihs2")
            //show correct VC based on userinfo
            Yellr.println(notification.userInfo)
            
        }
        
        if(application.applicationState == UIApplicationState.Active ) {
            //The application received a notification in the active state, so you can display an alert view or do something appropriate.
            Yellr.println("thisihs3")
            Yellr.println(notification.userInfo)
        }
        
    }
    
    //to take care of stuff after the app becomes active from local notify / or not
    //for iOS8
    //Part A - when app is opened from the notification (App was in inactive state)
    //Part B - when app is already opened, case for iOS8 handled above
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        Yellr.println("thisihs")
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

