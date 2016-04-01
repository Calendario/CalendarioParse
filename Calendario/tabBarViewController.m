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
    
    //retrieve today's date
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd"];
    NSString *currentDate = [dateFormat stringFromDate:today];
    
//    //center Tab button properties
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *buttonImage = [UIImage imageNamed:@"alternateTimeLine_Icon.png"];
//    button.frame = CGRectMake(0, 0, buttonImage.size.width*2, buttonImage.size.height*2);
//    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
//    button.contentMode = UIViewContentModeScaleAspectFit;
//    [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
//    button.titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:20];
//    [button setTitle: currentDate forState:UIControlStateNormal];
//    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, -23, 0)];
//    
//    
//    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height + 31;
//    if (heightDifference < 0)
//        button.center = self.tabBar.center;
//    else
//    {
//        CGPoint center = self.tabBar.center;
//        center.y = center.y - heightDifference/2.0;
//        button.center = center;
//    }
//    
//    [self.view addSubview:button];
//    [button addTarget:self action:@selector(centerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //tabBar icon properties **IF THESE ARE NOT IMPLEMENTED THEN THE ICONS WILL NOT STAY WHITE
//    [self.tabBar setTintColor:[UIColor whiteColor]];
    
    // also repeat for every tab
    UITabBarItem *firstTab = [self.tabBar.items objectAtIndex:0];
    UITabBarItem *secondTab = [self.tabBar.items objectAtIndex:1];
    UITabBarItem *thirdTab = [self.tabBar.items objectAtIndex:2];// no need to implement this as the custom button is covering it
    UITabBarItem *fourthTab = [self.tabBar.items objectAtIndex:3];
  //  UITabBarItem *fifthTab = [self.tabBar.items objectAtIndex:4];
    firstTab.image = [[UIImage imageNamed:@"newsFeed_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    firstTab.selectedImage = [[UIImage imageNamed:@"newsFeed_icon.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    secondTab.image = [[UIImage imageNamed:@"calendar_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    secondTab.selectedImage = [[UIImage imageNamed:@"calendar_icon.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    fourthTab.image = [[UIImage imageNamed:@"default_profile_pic.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    fourthTab.selectedImage = [[UIImage imageNamed:@"default_profile_pic.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //fifthTab.image = [[UIImage imageNamed:@"profile_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    //fifthTab.selectedImage = [[UIImage imageNamed:@"profile_icon.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    thirdTab.image = [[UIImage imageNamed:@"notifications_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    thirdTab.selectedImage = [[UIImage imageNamed:@"notiications_icon.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    for(UITabBarItem * tabBarItem in self.tabBar.items){
        tabBarItem.title = @"";
        tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }
}

- (IBAction)centerButtonClicked:(id)sender
{
    NSLog(@"center button pressed");
    [self setSelectedIndex:2];
    
}

@end
