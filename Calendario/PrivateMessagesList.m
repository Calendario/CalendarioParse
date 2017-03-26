//
//  PrivateMessagesList.m
//  Calendario
//
//  Created by Daniel Sadjadian on 21/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import "PrivateMessagesList.h"
#import "MessageUserSelector.h"
#import "MessageDetailView.h"

@interface PrivateMessagesList ()

@end

@implementation PrivateMessagesList

/// BUTTONS ///

-(IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [reloadTimer invalidate];
    }];
}

-(IBAction)createNewMessage:(id)sender {
    
    // Open the user selector view.
    UIStoryboard *storyFile = [UIStoryboard storyboardWithName:@"MessageUserSelector" bundle:nil];
    UIViewController *screen = [storyFile instantiateViewControllerWithIdentifier:@"MessageUserSelector"];
    [self presentViewController:screen animated:YES completion:nil];
}

-(IBAction)changeListType:(id)sender {
    [messagesList reloadData];
}

/// VIEW DID LOAD ///

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set the user selected notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSelected:) name:@"user_selected_private_message" object:nil];
    
    // Intialise the message arrays.
    messageData = [[NSMutableArray alloc] init];
    messageDataArchived = [[NSMutableArray alloc] init];
    
    // Load all the threads.
    [self loadThreadsForCurrentUser];
    
    // Keep checking for new threads (every 1.5 seconds).
    reloadTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(loadThreadsForCurrentUser) userInfo:nil repeats:YES];
}

/// DATA METHODS ///

-(void)userSelected:(NSNotification *)data {
    
    if (data != nil) {
        
        PFUser *user = (PFUser *)[data object];
        
        if ([messageData count] > 0) {
            
            PFObject *loopThread = nil;
            
            for (NSUInteger loop = 0; loop < [messageData count]; loop++) {
                
                // Get the loop data.
                PFObject *loopData = [messageData[loop] objectAtIndex:0];
                
                // Check if a message thread with the
                // selected user already exists or not.
                
                if (([[(PFUser *)[loopData valueForKey:@"userA"] objectId] isEqualToString:[user objectId]]) || ([[(PFUser *)[loopData valueForKey:@"userB"] objectId] isEqualToString:[user objectId]])) {
                    loopThread = loopData;
                    break;
                }
            }
            
            if (loopThread == nil) {
                [self checkArchivedMessages:user];
            } else {
                [self openExistingMessageThread:loopThread];
            }
            
        } else {
            [self checkArchivedMessages:user];
        }
    }
}

-(void)checkArchivedMessages:(PFUser *)user {
    
    if ([messageDataArchived count] > 0) {
        
        PFObject *loopThread = nil;
        
        for (NSUInteger loop = 0; loop < [messageDataArchived count]; loop++) {
            
            // Get the loop data.
            PFObject *loopData = [messageDataArchived[loop] objectAtIndex:0];
            
            // Check if a message thread with the
            // selected user already exists or not.
            
            if (([[(PFUser *)[loopData valueForKey:@"userA"] objectId] isEqualToString:[user objectId]]) || ([[(PFUser *)[loopData valueForKey:@"userB"] objectId] isEqualToString:[user objectId]])) {
                loopThread = loopData;
                break;
            }
        }
        
        if (loopThread == nil) {
            [self openNewMessageThread:user];
        } else {
            [self openExistingMessageThread:loopThread];
        }
        
    } else {
        [self openNewMessageThread:user];
    }
}

-(void)openNewMessageThread:(PFUser *)user {
    
    // Open the message detail view.
    UIStoryboard *storyFile = [UIStoryboard storyboardWithName:@"MessageDetailView" bundle:nil];
    MessageDetailView *screen = [storyFile instantiateViewControllerWithIdentifier:@"MessageDetailView"];
    [screen setPassedInUser:user];
    [self presentViewController:screen animated:YES completion:nil];
}

-(void)openExistingMessageThread:(PFObject *)thread {
    
    // Open the message detail view.
    UIStoryboard *storyFile = [UIStoryboard storyboardWithName:@"MessageDetailView" bundle:nil];
    MessageDetailView *screen = [storyFile instantiateViewControllerWithIdentifier:@"MessageDetailView"];
    [screen setPassedInThread:thread];
    [self presentViewController:screen animated:YES completion:nil];
}

-(void)loadThreadsForCurrentUser {
    
    // Setup the first thread data query.
    PFQuery *threadQueryA = [PFQuery queryWithClassName:@"privateMessageThreads"];
    [threadQueryA whereKey:@"userA" equalTo:[PFUser currentUser]];
    
    // Setup the second thread data query.
    PFQuery *threadQueryB = [PFQuery queryWithClassName:@"privateMessageThreads"];
    [threadQueryB whereKey:@"userB" equalTo:[PFUser currentUser]];
    
    // Create the overall message query (userA OR userB).
    PFQuery *messageQuery = [PFQuery orQueryWithSubqueries:@[threadQueryA, threadQueryB]];
    
    // Run the message thread query.
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (error == nil) {
            
            // Get the number of message threads.
            NSUInteger threadCount = [objects count];
            
            // Sort the data if we have any.
            
            if (threadCount > 0) {
                
                // Create the temporary arrays.
                NSMutableArray *tempData = [[NSMutableArray alloc] init];
                NSMutableArray *tempDataArchived = [[NSMutableArray alloc] init];
                
                // Loop through the data and sort it.
                
                for (NSUInteger loop = 0; loop < threadCount; loop++) {
                    
                    // Get the current loop data.
                    PFObject *thread = [objects objectAtIndex:loop];
                    
                    // Establish if the logged in user is userA or userB.
                    
                    if ([[(PFUser *)[thread valueForKey:@"userA"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                        
                        // Save the data if the user has NOT archived it.
                        
                        if ([[thread valueForKey:@"userAHidden"] boolValue] == NO) {
                            [tempData addObject:@[thread, @"A"]];
                        } else {
                            [tempDataArchived addObject:@[thread, @"A"]];
                        }
                        
                    } else {
                        
                        // Save the data if the user has NOT archived it.
                        
                        if ([[thread valueForKey:@"userBHidden"] boolValue] == NO) {
                            [tempData addObject:@[thread, @"B"]];
                        } else {
                            [tempDataArchived addObject:@[thread, @"B"]];
                        }
                    }
                }
                
                // Copy in the new thread data.
                messageData = [tempData mutableCopy];
                messageDataArchived = [tempDataArchived mutableCopy];
                
            } else {
                
                // Clear the message list.
                [messageData removeAllObjects];
                [messageDataArchived removeAllObjects];
            }
            
            // Refresh the table view.
            [messagesList reloadData];
            
        } else {
            
            // Display the error alert.
            [self displayAlert:@"Error" :error.localizedDescription];
        }
    }];
}

-(void)getPreviewForThread:(PFObject *)thread :(NSString *)otherUser :(threadCompletion)dataBlock {
    
    // Setup the message data query.
    PFQuery *messageQuery = [PFQuery queryWithClassName:@"privateMessagesMedia"];
    [messageQuery whereKey:@"threadID" equalTo:[thread objectId]];
    [messageQuery orderByDescending:@"createdAt"];
    
    // Run the message data query.
    [messageQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        if ((error == nil) && (object != nil)) {
            
            // Get the message type.
            NSString *messageType = [object valueForKey:@"typeData"];
            
            // Check the message type and create the
            // appropriate preview description string.
            
            if ([messageType isEqualToString:@"Text"]) {
                dataBlock([object valueForKey:@"textData"]);
            } else {
                
                // Create the name start string.
                NSString *startString = nil;
                
                // Check who sent the latest message.
                
                if ([[(PFUser *)[object valueForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                    startString = @"You";
                } else {
                    startString = otherUser;
                }
                
                // Create the preview message.
                
                if ([messageType isEqualToString:@"Photo"]) {
                    dataBlock([NSString stringWithFormat:@"%@ sent a photo.", startString]);
                }
                
                else if ([messageType isEqualToString:@"Map"]) {
                    dataBlock([NSString stringWithFormat:@"%@ shared a location.", startString]);
                }
                
                else if ([messageType isEqualToString:@"Video"]) {
                    dataBlock([NSString stringWithFormat:@"%@ sent a video.", startString]);
                }
                
                else if ([messageType isEqualToString:@"Audio"]) {
                    dataBlock([NSString stringWithFormat:@"%@ sent a voice message.", startString]);
                }
            }
            
        } else {
            dataBlock(nil);
        }
    }];
}

-(void)getUserCachedData:(NSString *)userID :(userCompletion)dataBlock {
    
    // Setup the user cache.
    static NSCache *userCache = nil;
    static dispatch_once_t onceToken;
    
    // Setup the cache object.
    
    dispatch_once(&onceToken, ^{
        userCache = [NSCache new];
    });
    
    // Access the user cache with the unique ID string.
    NSArray *cachedUserData = [userCache objectForKey:userID];
    
    // Check if the user data has been
    // previously stored in the cache.
    
    if (cachedUserData) {
        dataBlock(cachedUserData[0], cachedUserData[1]);
    }
    
    else {
        
        // Load the user profile data.
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" equalTo:userID];
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (error == nil) {
                
                // Download the user profile image.
                PFFile *userImageFile = object[@"profileImage"];
                [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    
                    if (error == nil) {
                        
                        // Set the profile image view.
                        UIImage *image = [UIImage imageWithData:imageData];
                        
                        // Save the user data in the cache.
                        [userCache setObject:@[[(PFUser *)object username], image] forKey:userID];
                        
                        dataBlock([(PFUser *)object username], image);
                        
                    } else {
                        dataBlock([(PFUser *)object username], nil);
                    }
                }];
                
            } else {
                dataBlock(nil, nil);
            }
        }];
    }
}

/// INFO METHODS ///

-(void)displayAlert:(NSString *)title :(NSString *)message {
    
    // Display the info alert.
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // Create the alert actions.
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    
    // Add the action and present the alert.
    [alert addAction:dismiss];
    [self presentViewController:alert animated:YES completion:nil];
}

/// UITABLEVIEW METHODS ///

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Deselect the selected table view cell.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (messageControl.selectedSegmentIndex == 0) {
        [self openExistingMessageThread:(PFObject *)[messageData[indexPath.row] objectAtIndex:0]];
    } else {
        [self openExistingMessageThread:(PFObject *)[messageDataArchived[indexPath.row] objectAtIndex:0]];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Delegate call back for cell at index path.
    static NSString *CellIdentifier = @"MessagePreviewCell";
    MessagePreviewCell *cell = (MessagePreviewCell *)[messagesList dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessagePreviewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Check if there is any message data.
    
    if ((messageControl.selectedSegmentIndex == 0 ? [messageData count] : [messageDataArchived count]) > 0) {
        
        // Show all the main views.
        cell.profilePicture.alpha = 1.0;
        cell.titleLabel.alpha = 1.0;
        cell.descriptionLabel.alpha = 1.0;
        cell.dateLabel.alpha = 1.0;
        
        // Hide the no message label.
        cell.noMessagesLabel.alpha = 0.0;
        
        // Get the current table view data object.
        PFObject *data = nil;
        
        // Get the current data object user.
        NSString *userCheck = nil;
        
        if (messageControl.selectedSegmentIndex == 0) {
            data = [messageData[indexPath.row] objectAtIndex:0];
            userCheck = [messageData[indexPath.row] objectAtIndex:1];
        } else {
            data = [messageDataArchived[indexPath.row] objectAtIndex:0];
            userCheck = [messageDataArchived[indexPath.row] objectAtIndex:1];
        }
        
        // Create the user ID string.
        NSString *userID = nil;
        
        // Get the other user's unique ID string.
        
        if ([userCheck isEqualToString:@"A"]) {
            userID = [(PFUser *)[data valueForKey:@"userB"] objectId];
        } else {
            userID = [(PFUser *)[data valueForKey:@"userA"] objectId];
        }
        
        // Change the user pciture into a circle.
        CGPoint saveCenter = cell.profilePicture.center;
        CGRect newFrame = CGRectMake(cell.profilePicture.frame.origin.x, cell.profilePicture.frame.origin.y, 48.0, 48.0);
        cell.profilePicture.frame = newFrame;
        cell.profilePicture.layer.cornerRadius = (50.0 / 2.0);
        cell.profilePicture.center = saveCenter;
        
        // Get the other user's profile data.
        [self getUserCachedData:userID :^(NSString *username, UIImage *picture) {
            
            if (picture == nil) {
                [cell.profilePicture setImage:[UIImage imageNamed:@"default_profile_pic.png"]];
            } else {
                [cell.profilePicture setImage:picture];
            }
            
            // Get the latest message of the thread.
            [self getPreviewForThread:data :username :^(NSString *preview) {
                
                if (preview == nil) {
                    [cell.descriptionLabel setText:@"-"];
                } else {
                    [cell.descriptionLabel setText:preview];
                }
            }];
            
            [cell.titleLabel setText:username];
        }];
        
    } else {
        
        // Hide all the main views.
        cell.profilePicture.alpha = 0.0;
        cell.titleLabel.alpha = 0.0;
        cell.descriptionLabel.alpha = 0.0;
        cell.dateLabel.alpha = 0.0;
        
        // Show the no message label.
        cell.noMessagesLabel.alpha = 1.0;
    }
        
    // Set the cell selected background colour.
    UIView *selectedBackground = [[UIView alloc] init];
    [selectedBackground setBackgroundColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:0.3f]];
    [cell setSelectedBackgroundView:selectedBackground];
    
    // Set the content restraints.
    [cell.profilePicture setClipsToBounds:YES];
    [cell.titleLabel setClipsToBounds:YES];
    [cell.descriptionLabel setClipsToBounds:YES];
    [cell.dateLabel setClipsToBounds:YES];
    [cell.noMessagesLabel setClipsToBounds:YES];
    [cell.contentView setClipsToBounds:NO];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Setup the initial cell properties before
    // the cell has been loaded and presented.
    cell.alpha = 0.0;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut animations:^{
        
        // Display the custom cell.
        cell.alpha = 1.0;
        
    } completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (messageControl.selectedSegmentIndex == 0) {
        return ([messageData count] > 0 ? 76 : messagesList.frame.size.height);
    } else {
        return ([messageDataArchived count] > 0 ? 76 : messagesList.frame.size.height);
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (messageControl.selectedSegmentIndex == 0) {
        return ([messageData count] > 0 ? [messageData count] : 1);
    } else {
        return ([messageDataArchived count] > 0 ? [messageDataArchived count] : 1);
    }
}

/// OTHER METHODS ///

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
