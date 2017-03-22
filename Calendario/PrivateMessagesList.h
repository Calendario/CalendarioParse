//
//  PrivateMessagesList.h
//  Calendario
//
//  Created by Daniel Sadjadian on 21/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "MessagePreviewCell.h"

typedef void(^userCompletion)(NSString *username, UIImage *picture);
typedef void(^threadCompletion)(NSString *preview);

@interface PrivateMessagesList : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    // Messages table view.
    IBOutlet UITableView *messagesList;
    
    // Main messages array.
    NSMutableArray *messageData;
}

// Buttons.
-(IBAction)done:(id)sender;
-(IBAction)createNewMessage:(id)sender;

// Data methods.
-(void)userSelected:(NSNotification *)data;
-(void)loadThreadsForCurrentUser;
-(void)getPreviewForThread:(NSString *)threadID :(NSString *)otherUser :(threadCompletion)dataBlock;
-(void)getUserCachedData:(NSString *)userID :(userCompletion)dataBlock;

// Info methods.
-(void)displayAlert:(NSString *)title :(NSString *)message;

@end
