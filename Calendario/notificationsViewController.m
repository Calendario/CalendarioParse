//
//  notificationsViewController.m
//  Calendario
//
//  Created by Larry B. King on 12/16/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

#import "notificationsViewController.h"
#import <Parse/Parse.h>
#import "Calendario-Swift.h"

@class ManageUser;
@interface notificationsViewController ()
{
    NSMutableArray *notificationUsers;
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
    
    // Download the user notifications.
    [ManageUser getUserNotifications:[PFUser currentUser] completion:^(NSArray *userData, NSArray *notificationData) {
        
        // Only load the data if one or
        // more notifications are present.
        
        if ([userData count] > 0) {
            
            // Initialise the data arrays with the
            // downloaded user notification data.
            notificationUsers = [[NSMutableArray alloc] initWithArray:userData];
            notifications = [[NSMutableArray alloc] initWithArray:notificationData];
            
            // Update the table view.
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                [self.tableView reloadData];
            }];
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
    
    // Setup the table view cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell" forIndexPath:indexPath];
    
    // Get the cell UI objects.
    UIImageView *userImageView = (UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *usernameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *actionLabel = (UILabel *)[cell.contentView viewWithTag:3];
    
    // Set the notification label.
    NSString *notificationAction = notifications[indexPath.row];
    actionLabel.text = notificationAction;
    
    // Download the user data.
    PFQuery *imageQuery = [PFUser query];
    [imageQuery whereKey:@"objectId" equalTo:((PFUser *)notificationUsers[indexPath.row]).objectId];
    [imageQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if (error == nil) {
            
            // Set the username label.
            usernameLabel.text = [NSString stringWithFormat:@"@%@", ((PFUser *)object).username];
            
            // Download the user image.
            PFFile *userImageFile = object[@"profileImage"];
            [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                
                if (error == nil) {
                    
                    // Set the profile image view & the various proerties.
                    UIImage *image = [UIImage imageWithData:imageData];
                    [userImageView setImage:image];
                    userImageView.layer.cornerRadius = (userImageView.frame.size.width / 2);
                    userImageView.clipsToBounds = YES;
                    userImageView.layer.borderWidth = 1.0f;
                    userImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                }
            }];
        }
    }];
    
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
