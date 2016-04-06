//
//  tabBarViewController.m
//  Calendario
//
//  Created by Larry B. King on 10/20/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

#import "tabBarViewController.h"
#import "AppDelegate.h"

@interface tabBarViewController ()

@end

@implementation tabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setTabBarIcons];
    [self setTabBarIconTitles];
}

- (void) setupUI {
    self.tabBar.tintColor = [UIColor colorWithRed:33/255.0 green:135/255.0 blue:75/255.0 alpha:1.0];
}

- (void) setTabBarIconTitles {
    for(UITabBarItem * tabBarItem in self.tabBar.items){
        tabBarItem.title = @"";
        tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }
}

- (void) setTabBarIcons {
    UITabBarItem *firstTab = [self.tabBar.items objectAtIndex:0];
    UITabBarItem *secondTab = [self.tabBar.items objectAtIndex:1];
    UITabBarItem *thirdTab = [self.tabBar.items objectAtIndex:2];
    UITabBarItem *fourthTab = [self.tabBar.items objectAtIndex:3];
    
    firstTab.image = [[UIImage imageNamed:@"newsFeed_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
    secondTab.image = [[UIImage imageNamed:@"calendar_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
    fourthTab.image = [[UIImage imageNamed:@"default_profile_pic.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
    thirdTab.image = [[UIImage imageNamed:@"notifications_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
}


@end
