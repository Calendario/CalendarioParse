//
//  notificationsViewController.m
//  Calendario
//
//  Created by Larry B. King on 12/16/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

#import "notificationsViewController.h"
#import <Parse/Parse.h>

@interface notificationsViewController ()
{
    NSMutableArray *notifications;
}

@end

@implementation notificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    notifications = [NSMutableArray new];
}

- (void) getNotifications {
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *notifQuery = [PFQuery queryWithClassName:@"User"];
    [notifQuery getObjectInBackgroundWithId:currentUser.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
            [notifications addObjectsFromArray: [object objectForKey:@"notifications"]];
        }
        else
        {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return notifications.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell" forIndexPath:indexPath];
    
    UILabel *actionLabel = (UILabel *)[cell.contentView viewWithTag:1];
    
    NSString *notificationAction = notifications [indexPath.row];
    
    actionLabel.text = notificationAction;
    
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}


@end
