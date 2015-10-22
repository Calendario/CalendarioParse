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
    
    //center Tab button properties
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"statusUpdate_icon.png"];
    button.frame = CGRectMake(0, 0, buttonImage.size.width*2, buttonImage.size.height*2);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height + 31;
    if (heightDifference < 0)
        button.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    
    [self.view addSubview:button];
    [button addTarget:self action:@selector(centerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //tabBar icon properties **IF THESE ARE NOT IMPLEMENTED THEN THE ICONS WILL NOT STAY WHITE
    [self.tabBar setTintColor:[UIColor whiteColor]];
    
    // also repeat for every tab
    UITabBarItem *firstTab = [self.tabBar.items objectAtIndex:0];
    UITabBarItem *secondTab = [self.tabBar.items objectAtIndex:1];
    UITabBarItem *thirdTab = [self.tabBar.items objectAtIndex:2];// no need to implement this as the custom button is covering it
    UITabBarItem *fourthTab = [self.tabBar.items objectAtIndex:3];
    UITabBarItem *fifthTab = [self.tabBar.items objectAtIndex:4];
    firstTab.image = [[UIImage imageNamed:@"newsFeed_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    firstTab.selectedImage = [[UIImage imageNamed:@"newsFeed_icon.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    secondTab.image = [[UIImage imageNamed:@"smallSearch_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    secondTab.selectedImage = [[UIImage imageNamed:@"smallSearch_icon.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    fourthTab.image = [[UIImage imageNamed:@"notifications_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    fourthTab.selectedImage = [[UIImage imageNamed:@"notifications_icon.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    fifthTab.image = [[UIImage imageNamed:@"profile_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    fifthTab.selectedImage = [[UIImage imageNamed:@"profile_icon.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    thirdTab.image = [[UIImage imageNamed:@"statusUpdate_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    thirdTab.selectedImage = [[UIImage imageNamed:@"statusUpdate_icon.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    for(UITabBarItem * tabBarItem in self.tabBar.items){
        tabBarItem.title = @"";
        tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)centerButtonClicked:(id)sender
{
    NSLog(@"center button pressed");
    [self setSelectedIndex:2];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}


@end
