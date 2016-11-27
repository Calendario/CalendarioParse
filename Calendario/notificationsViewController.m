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

typedef void(^userProfileDataCompletion)(PFObject *object, NSError *error);

@class ManageUser;
@interface notificationsViewController () {
    
    // Notification data arrays.
    NSMutableArray *notificationUsers;
    NSMutableArray *notifications;
    NSMutableArray *notificationsExtLinks;
    NSMutableArray *notificationDates;
}

@end

@implementation notificationsViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
    
    [self getNotifications];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
        
    [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:nil];
}

-(void)getNotifications {
    
    // Download the user notifications.
    [ManageUser getUserNotifications:[PFUser currentUser] completion:^(NSArray *userData, NSArray *notificationData, NSArray *extLinks, NSArray *notificationDate) {
        
        // Only load the data if one or
        // more notifications are present.
        
        if ([userData count] > 0) {
            
            // Initialise the data arrays with the
            // downloaded user notification data.
            notificationUsers = [[NSMutableArray alloc] initWithArray:[[userData reverseObjectEnumerator] allObjects]];
            notifications = [[NSMutableArray alloc] initWithArray:[[notificationData reverseObjectEnumerator] allObjects]];
            notificationsExtLinks = [[NSMutableArray alloc] initWithArray:[[extLinks reverseObjectEnumerator] allObjects]];
            notificationDates = [[NSMutableArray alloc] initWithArray:[[notificationDate reverseObjectEnumerator] allObjects]];
            
            // Update the table view.
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                [self.tableView reloadData];
            }];
        }
    }];
}

-(void)getUserProfileDetails:(NSIndexPath *)indexPath :(userProfileDataCompletion)dataBlock {
    
    // Download the user data.
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:((PFUser *)notificationUsers[indexPath.row]).objectId];
    [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        dataBlock(object, error);
    }];
}

-(UIImage *)checkActionType: (NSString *)type {
    if ([type isEqualToString:@"comment"]) {
        UIImage *commentIcon = [UIImage imageNamed:@"comment-icon"];
        return commentIcon;
    }
    else if ([type isEqualToString:@"like"]) {
        UIImage *likeIcon = [UIImage imageNamed:@"like-icon"];
        return likeIcon;
    }
    else if ([type isEqualToString:@"rsvp"]) {
        UIImage *attendIcon = [UIImage imageNamed:@"attend-icon"];
        return attendIcon;
    }
    else {
        UIImage *likeIcon = [UIImage imageNamed:@"like-icon"];
        return likeIcon;
    }
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (notifications.count > 30) {
        return 30;
    } else {
        return notifications.count;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Disable table view access until the taks is complete.
    [self.tableView setUserInteractionEnabled:NO];
    
    // Open the appropriate controller depending on the notification type - user, comment, etc..
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if ([[notificationsExtLinks[indexPath.row] objectAtIndex:0] isEqualToString:@"user"]) {
        
        // Get the user data before opening
        // the profile view controller.
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" equalTo:((PFUser *)notificationUsers[indexPath.row]).objectId];
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (error == nil) {
                
                // Show the notification user profile view.
                MyProfileViewController *profVC = [mainSB instantiateViewControllerWithIdentifier:@"My Profile"];
                profVC.passedUser = (PFUser *)object;
                profVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                [self presentViewController:profVC animated:YES completion:^{
                    
                    // Re-enable table view access.
                    [self.tableView setUserInteractionEnabled:YES];
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                }];
            }
            
            else {
                
                // Re-enable table view access.
                [self.tableView setUserInteractionEnabled:YES];
            }
        }];
    }
    
    else if (([[notificationsExtLinks[indexPath.row] objectAtIndex:0] isEqualToString:@"comment"]) || ([[notificationsExtLinks[indexPath.row] objectAtIndex:0] isEqualToString:@"like"])) {
        
        // Load the status update object.
        PFQuery *objectQuery = [PFQuery queryWithClassName:@"StatusUpdate"];
        [objectQuery whereKey:@"objectId" equalTo:[NSString stringWithFormat:@"%@", [notificationsExtLinks[indexPath.row] objectAtIndex:1]]];
        [objectQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            
            if (error == nil) {
                
                // Check if the status update has an image.
                
                if ([object valueForKey:@"image"] == nil) {
                    
                    // Re-enable table view access.
                    [self.tableView setUserInteractionEnabled:YES];
                    
                    // Open the see more view without the image.
                    [self openSeeMoreView:object :tableView :indexPath :mainSB :nil];
                }
                
                else {
                    
                    // Download the user image.
                    PFFile *userImageFile = object[@"image"];
                    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                        
                        // Re-enable table view access.
                        [self.tableView setUserInteractionEnabled:YES];
                        
                        if (error == nil) {
                            
                            // Set the profile image view & the various proerties.
                            UIImage *image = [UIImage imageWithData:imageData];
                            
                            // Open the see more view with the image.
                            [self openSeeMoreView:object :tableView :indexPath :mainSB :image];
                        }
                        
                        else {
                            
                            // Open the see more view without the image.
                            [self openSeeMoreView:object :tableView :indexPath :mainSB :nil];
                        }
                    }];
                }
            }
            
            else {
                
                // Re-enable table view access.
                [self.tableView setUserInteractionEnabled:YES];
                
                // Display the error alert.
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                
                // Create the alert actions.
                UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                
                // Add the action and present the alert.
                [alert addAction:dismiss];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
}

-(void)openSeeMoreView:(PFObject *)object :(UITableView *)tableView :(NSIndexPath *)indexPath :(UIStoryboard *)mainSB :(UIImage *)imageData {
    
    // Show the see more for the selected notification.
    CommentsViewController *commentvc = [mainSB instantiateViewControllerWithIdentifier:@"comments"];
    commentvc.savedobjectID = [NSString stringWithFormat:@"%@", [notificationsExtLinks[indexPath.row] objectAtIndex:1]];
    commentvc.passedInObjectForSeeMoreView = object;
    commentvc.passedInImage = imageData;
    commentvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:commentvc];
    [self presentViewController:navController animated:YES completion:^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Setup the table view cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell" forIndexPath:indexPath];
    
    // Get the cell UI objects.
    UIImageView *userImageView = (UIImageView *)[cell.contentView viewWithTag:1];
    UILabel *usernameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UIButton *actionButton = (UIButton *)[cell.contentView viewWithTag:3];
    UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:4];
    actionButton.layer.cornerRadius = 2.0;
    
    // Check for action type.
    NSString *type = [notificationsExtLinks[indexPath.row] objectAtIndex:0];
    [actionButton setImage:[self checkActionType:type] forState:UIControlStateNormal];
    
    // Set the date label colour.
    dateLabel.textColor = [UIColor lightGrayColor];
    
    // Download the user profile data.
    [self getUserProfileDetails:indexPath :^(PFObject *object, NSError *error) {
        
        // Set the notification label.
        NSString *notificationAction = notifications[indexPath.row];
        
        // Check for data errors.
        
        if (error == nil) {
            
            NSString *originalString = notificationAction;
            usernameLabel.text = originalString;
            
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:usernameLabel.text];
            NSArray *words = [usernameLabel.text componentsSeparatedByString:@" "];
            
            if (words.firstObject) {
                NSRange range = [usernameLabel.text rangeOfString: words.firstObject];
                [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:33/255.0f green:135/255.0f blue:75/255.0f alpha:1.0f] range:range];
            }
            
            usernameLabel.attributedText = string;
            
            // Download the user image.
            PFFile *userImageFile = object[@"profileImage"];
            [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                
                if (error == nil) {
                    
                    // Set the profile image view.
                    UIImage *image = [UIImage imageWithData:imageData];
                    [userImageView setImage:image];
                    
                } else {
                    
                    // Set the default profile picture.
                    userImageView.image = [UIImage imageNamed:@"default_profile_pic.png"];
                }
                
                // Turn the image view into a circle.
                userImageView.layer.cornerRadius = (userImageView.frame.size.width / 2);
                userImageView.clipsToBounds = YES;
                
                [cell performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
            }];
        }
    }];
    
    // Check if the notification NSDate exists.
    
    if (indexPath.row < [notificationDates count]) {
        
        // Create the short hand date string.
        [DateManager createDateDifferenceString:notificationDates[indexPath.row] :YES completion:^(NSString *dateString) {
            dateLabel.text = dateString;
        }];
    } else {
        dateLabel.text = @"";
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

// Override to support conditional rearranging of the table view.
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

@end
