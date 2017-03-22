//
//  MessageUserSelector.h
//  Calendario
//
//  Created by Daniel Sadjadian on 22/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "MessageUserCell.h"

typedef void(^userCompletion)(NSString *username, UIImage *picture);

@interface MessageUserSelector : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
    
    // User search list.
    IBOutlet UITableView *userList;
    
    // User search bar.
    IBOutlet UISearchBar *userSearchBar;
    
    // User data array.
    NSMutableArray *userData;
}

// Buttons.
-(IBAction)done:(id)sender;

// Data methods.
-(void)searchForUser:(NSString *)username;
-(void)getUserCachedData:(NSString *)userID :(userCompletion)dataBlock;

@end
