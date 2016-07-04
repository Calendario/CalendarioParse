//
//  tabBarViewController.m
//  Calendario
//
//  Created by Larry B. King on 10/20/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

#import "tabBarViewController.h"
#import "AppDelegate.h"
#import "Calendario-Swift.h"

@interface tabBarViewController ()

@end

@implementation tabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setTabBarIcons];
    [self setTabBarIconTitles];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self setNotificationBadge];
}

- (void) setupUI {
    self.tabBar.tintColor = [UIColor colorWithRed:33/255.0 green:135/255.0 blue:75/255.0 alpha:1.0];
}

- (void) setTabBarIconTitles {
    
    for (UITabBarItem * tabBarItem in self.tabBar.items) {
        tabBarItem.title = @"";
        tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }
}

- (void) setTabBarIcons {
    UITabBarItem *firstTab = [self.tabBar.items objectAtIndex:0];
    UITabBarItem *secondTab = [self.tabBar.items objectAtIndex:1];
    UITabBarItem *thirdTab = [self.tabBar.items objectAtIndex:2];
    UITabBarItem *fourthTab = [self.tabBar.items objectAtIndex:3];
    
    firstTab.image = [[UIImage imageNamed:@"newsFeed_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    secondTab.image = [[UIImage imageNamed:@"searchTabLogo.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    thirdTab.image = [[UIImage imageNamed:@"notifications_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    fourthTab.image = [[UIImage imageNamed:@"default_profile_pic.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(void)setNotificationBadge {
    
    // Get the notification tab bar item.
    UITabBarItem *thirdTab = [self.tabBar.items objectAtIndex:2];
    
    // Download the user notifications data.
    [ManageUser getUserNotifications:[PFUser currentUser] completion:^(NSArray *userData, NSArray *notificationData, NSArray *extLinks) {
        
        // Update the UI on the main thread.
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            
            // Set the notifications tab bar badge.
            
            if ([userData count] > 0) {
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSInteger badgeNum = [defaults integerForKey:@"NOTIFICATION_BADGE_NUM"];
                
                if ([defaults valueForKey:@"NOTIFICATION_BADGE_NUM"] == nil) {
                    
                    // One or more notification(s) - show badge number.
                    [thirdTab setBadgeValue:[NSString stringWithFormat:@"%lu", (unsigned long)[userData count]]];
                }
                
                else if ([userData count] > badgeNum) {
                    
                    // Figure out the number of NEW notifications.
                    NSInteger newNotifications = ([userData count] - badgeNum);
                    
                    // One or more notification(s) - show badge number.
                    [thirdTab setBadgeValue:[NSString stringWithFormat:@"%lu", (long)newNotifications]];
                }
                
                else {
                    [thirdTab setBadgeValue:nil];
                }
                
                // Save the new total notification count.
                [defaults setInteger:[userData count] forKey:@"NOTIFICATION_BADGE_NUM"];
                [defaults synchronize];
            }
            
            else {
                
                // No user notification - hide badge.
                [thirdTab setBadgeValue:nil];
            }
        }];
    }];
}

@end
