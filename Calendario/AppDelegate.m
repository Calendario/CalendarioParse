//
//  AppDelegate.m
//  Calendario
//
//  Created by Derek Cacciotti on 10/10/15.
//  Copyright © 2015 Derek Cacciotti. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "tabBarViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //reference uiTabBar and set ui properties
    //reference the uitabBar
    UITabBar *tabBar = [UITabBar appearance];
    
    //uiTabBar appearance properties
    tabBar.backgroundColor = [UIColor colorWithRed:46/255.0 green:153/255.0 blue:80/255.0 alpha:1.0];
    tabBar.barTintColor = [UIColor colorWithRed:46/255.0 green:153/255.0 blue:80/255.0 alpha:1.0];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setShadowImage:nil];
    return YES;
    
    
    // Override point for customization after application launch.
    // Initialize Parse.
    [Parse setApplicationId:@"p8YhMVSoCmZvl5tBbpvdk2CK3BYmqwC3p9VS4kPI"
                  clientKey:@"fyHr9RFkqoeefvQxX92J1RBAKnm1s4aqDLRDhAgr"];
    
    
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
