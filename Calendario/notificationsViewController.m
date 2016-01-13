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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self getNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

- (void) getNotifications {
    
    notifications = [NSMutableArray new];
    
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *notifQuery = [PFUser query];
    [notifQuery whereKey:@"objectId" equalTo:currentUser.objectId];
    [notifQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
            PFUser *retrievedUser = object;
            [notifications addObjectsFromArray: [retrievedUser objectForKey:@"notifications"]];
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
