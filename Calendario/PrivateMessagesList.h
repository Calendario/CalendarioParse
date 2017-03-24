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
    
    // Message display control.
    IBOutlet UISegmentedControl *messageControl;
    
    // Main messages array.
    NSMutableArray *messageData;
    NSMutableArray *messageDataArchived;
    
    // Data reload timer.
    NSTimer *reloadTimer;
}

// Buttons.
-(IBAction)done:(id)sender;
-(IBAction)createNewMessage:(id)sender;
-(IBAction)changeListType:(id)sender;

// Data methods.
-(void)userSelected:(NSNotification *)data;
-(void)checkArchivedMessages:(PFUser *)user;
-(void)openNewMessageThread:(PFUser *)user;
-(void)openExistingMessageThread:(PFObject *)thread;
-(void)loadThreadsForCurrentUser;
-(void)getPreviewForThread:(PFObject *)thread :(NSString *)otherUser :(threadCompletion)dataBlock;
-(void)getUserCachedData:(NSString *)userID :(userCompletion)dataBlock;

// Info methods.
-(void)displayAlert:(NSString *)title :(NSString *)message;

@end
