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
    // Do any additional setup after loading the view.
    
    // also repeat for every tab
    UITabBarItem *firstTab = [self.tabBar.items objectAtIndex:0];
    UITabBarItem *secondTab = [self.tabBar.items objectAtIndex:1];
    UITabBarItem *thirdTab = [self.tabBar.items objectAtIndex:2];// no need to implement this as the custom button is covering it
    UITabBarItem *fourthTab = [self.tabBar.items objectAtIndex:3];
  //  UITabBarItem *fifthTab = [self.tabBar.items objectAtIndex:4];
    firstTab.image = [[UIImage imageNamed:@"newsFeed_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
//    firstTab.selectedImage = [[UIImage imageNamed:@"newsFeed_icon.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    secondTab.image = [[UIImage imageNamed:@"calendar_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
//    secondTab.selectedImage = [[UIImage imageNamed:@"calendar_icon.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    fourthTab.image = [[UIImage imageNamed:@"default_profile_pic.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
//    fourthTab.selectedImage = [[UIImage imageNamed:@"default_profile_pic.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //fifthTab.image = [[UIImage imageNamed:@"profile_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    //fifthTab.selectedImage = [[UIImage imageNamed:@"profile_icon.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    thirdTab.image = [[UIImage imageNamed:@"notifications_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ];
//    thirdTab.selectedImage = [[UIImage imageNamed:@"notiications_icon.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.tabBar.tintColor = [UIColor colorWithRed:33/255.0 green:135/255.0 blue:75/255.0 alpha:1.0];
    for(UITabBarItem * tabBarItem in self.tabBar.items){
        tabBarItem.title = @"";
        tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }
}


@end
