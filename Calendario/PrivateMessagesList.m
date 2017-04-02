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
#import "ThreadDataObject.h"

@interface PrivateMessagesList ()

@end

@implementation PrivateMessagesList
@synthesize dataHelper;

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
    [self updateNoDataLabel];
    [messagesList reloadData];
}

/// VIEW DID LOAD ///

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set the user selected notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSelected:) name:@"user_selected_private_message" object:nil];
    
    // Make an object for the Private Messages Helper class.
    self.dataHelper = [[PrivateMessagesHelper alloc] init];
    
    // Intialise the message arrays.
    messageData = [[NSMutableArray alloc] init];
    messageDataArchived = [[NSMutableArray alloc] init];
    
    // Hide the no data label by default.
    [noDataLabel setAlpha:0.0];
    
    // Load all the threads.
    [self loadThreadsForCurrentUser];
    
    // Keep checking for new threads (every 1.5 seconds).
    reloadTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(loadThreadsForCurrentUser) userInfo:nil repeats:YES];
}

/// DATA METHODS ///

-(void)userSelected:(NSNotification *)data {
    
    // Check if auser object has been returned.
    
    if (data != nil) {
        
        // Get the user data object.
        PFUser *user = (PFUser *)[data object];
        
        // Check if we currently have any message threads.
        
        if ([messageData count] > 0) {
            
            // Create the loop thread object.
            PFObject *loopThread = nil;
            
            // Loop through the current data and check for
            // existing threads with the passed in user.
            
            for (NSUInteger loop = 0; loop < [messageData count]; loop++) {
                
                // Get the loop data.
                PFObject *loopData = [(ThreadDataObject *)[messageData[loop] objectAtIndex:0] threadObject];
                
                // Check if a message thread with the
                // selected user already exists or not.
                
                if (([[(PFUser *)[loopData valueForKey:@"userA"] objectId] isEqualToString:[user objectId]]) || ([[(PFUser *)[loopData valueForKey:@"userB"] objectId] isEqualToString:[user objectId]])) {
                    loopThread = loopData;
                    break;
                }
            }
            
            // If an existing thread is available then open
            // it otherwise check the archived threads.
            
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
    
    // Check if we currently have any message threads.
    
    if ([messageDataArchived count] > 0) {
        
        // Create the loop thread object.
        PFObject *loopThread = nil;
        
        // Loop through the current data and check for
        // existing threads with the passed in user.
        
        for (NSUInteger loop = 0; loop < [messageDataArchived count]; loop++) {
            
            // Get the loop data.
            PFObject *loopData = [(ThreadDataObject *)[messageDataArchived[loop] objectAtIndex:0] threadObject];
            
            // Check if a message thread with the
            // selected user already exists or not.
            
            if (([[(PFUser *)[loopData valueForKey:@"userA"] objectId] isEqualToString:[user objectId]]) || ([[(PFUser *)[loopData valueForKey:@"userB"] objectId] isEqualToString:[user objectId]])) {
                loopThread = loopData;
                break;
            }
        }
        
        // If an existing thread is available then open
        // it otherwise create a new message thread.
        
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
    
    // Load the logged in user's private message threads.
    [self.dataHelper getUserThreadsWithInfo:^(NSMutableArray *allData) {
        
        // Check if there is any thread data.
        
        if (allData != nil) {
            
            // Get the number of message threads.
            NSUInteger threadCount = [allData count];
            
            // Sort the data if we have any.
            
            if (threadCount > 0) {
                
                // Create the temporary arrays.
                NSMutableArray *tempData = [[NSMutableArray alloc] init];
                NSMutableArray *tempDataArchived = [[NSMutableArray alloc] init];
                
                // Loop through the data and sort it.
                
                for (NSUInteger loop = 0; loop < threadCount; loop++) {
                    
                    // Get the current loop data object.
                    ThreadDataObject *loopData = [allData objectAtIndex:loop];
                    
                    // Get the current loop thread data.
                    PFObject *thread = [loopData threadObject];
                    
                    // Establish if the logged in user is userA or userB.
                    
                    if ([[(PFUser *)[thread valueForKey:@"userA"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                        
                        // Save the data if the user has NOT archived it.
                        
                        if ([[thread valueForKey:@"userAHidden"] boolValue] == NO) {
                            [tempData addObject:@[loopData, @"A"]];
                        } else {
                            [tempDataArchived addObject:@[loopData, @"A"]];
                        }
                        
                    } else {
                        
                        // Save the data if the user has NOT archived it.
                        
                        if ([[thread valueForKey:@"userBHidden"] boolValue] == NO) {
                            [tempData addObject:@[loopData, @"B"]];
                        } else {
                            [tempDataArchived addObject:@[loopData, @"B"]];
                        }
                    }
                }
                
                // Depending on the current view mode perform
                // the correct table view cell data updates.
                
                if (messageControl.selectedSegmentIndex == 0) {
                    
                    // Archived data can just be copied as
                    // we are in the inbox table view mode.
                    messageDataArchived = [tempDataArchived mutableCopy];
                    
                    // Check if we currently have any data on display.
                    
                    if ([messageData count] > 0) {
                        
                        // Create the new objects array.
                        NSMutableArray *newDataObjects = [[NSMutableArray alloc] init];
                        
                        // Loop through the downloaded data and add
                        // any new objects to the current data array.
                        
                        for (NSUInteger newDataLoop = 0; newDataLoop < [tempData count]; newDataLoop++) {
                            
                            // Create the new data check.
                            BOOL addDataCheck = YES;
                            
                            // Get the new data object.
                            ThreadDataObject *data = (ThreadDataObject *)[tempData[newDataLoop] objectAtIndex:0];
                            
                            // Loop through the current data array and check
                            // if there are any copies of the downloaded data.
                            
                            for (NSUInteger currentDataLoop = 0; currentDataLoop < [messageData count]; currentDataLoop++) {
                                
                                // Get the current message data object.
                                ThreadDataObject *currentData = [messageData[currentDataLoop] objectAtIndex:0];
                                
                                // Check if the data already exists.
                                
                                if ([[[data threadObject] objectId] isEqualToString:[[currentData threadObject] objectId]]) {
                                    
                                    // Check if the new data contains
                                    // a message preview data object.
                                    
                                    if ([data latestMessage] != nil) {
                                        
                                        // Check if the current data contains
                                        // a message preview data object.
                                        
                                        if ([currentData latestMessage] != nil) {
                                            
                                            // Check if the new and current message
                                            // preview objects are the same or not.
                                            
                                            if ([[[data latestMessage] objectId] isEqualToString:[[currentData latestMessage] objectId]]) {
                                                
                                                // No new message preview objects have been
                                                // made however an existing one has been updated.
                                                
                                                if ([[data unreadCount] intValue] != [[currentData unreadCount] intValue]) {
                                                    [self refreshListCell:currentDataLoop :tempData[newDataLoop] :YES];
                                                }
                                                
                                            } else {
                                                [self refreshListCell:currentDataLoop :tempData[newDataLoop] :YES];
                                            }
                                            
                                        } else {
                                            [self refreshListCell:currentDataLoop :tempData[newDataLoop] :YES];
                                        }
                                    } else {
                                        
                                        // Check if the current data contains
                                        // a message preview data object.
                                        
                                        if ([currentData latestMessage] != nil) {
                                            [self refreshListCell:currentDataLoop :tempData[newDataLoop] :YES];
                                        }
                                    }
                                    
                                    // We are not adding new additional data.
                                    addDataCheck = NO;
                                    break;
                                }
                            }
                            
                            // Add the downloaded data if it does not
                            // exist in the current data array otherwise
                            // check if existing data needs updating.
                            
                            if (addDataCheck == YES) {
                                [newDataObjects insertObject:tempData[newDataLoop] atIndex:0];
                            }
                        }
                        
                        // Get the size of the new data array.
                        NSUInteger newSize = [newDataObjects count];
                        
                        // Check if there are any new data objects.
                        
                        if (newSize > 0) {
                            
                            // Create the table view index array.
                            NSMutableArray *indexes = [[NSMutableArray alloc] init];
                            
                            // Create the new NSIndexPath objects.
                            
                            for (NSUInteger loop = 1; loop < (newSize + 1); loop++) {
                                [indexes addObject:[NSIndexPath indexPathForRow:(([messageData count] - 1) + loop) inSection:0]];
                            }
                            
                            // Add the new data to the current array.
                            [messageData addObjectsFromArray:newDataObjects];
                            
                            // Add the new thread cells to the table view.
                            [messagesList insertRowsAtIndexPaths:newDataObjects withRowAnimation:UITableViewRowAnimationAutomatic];
                        }
                        
                    } else {
                        
                        // Reload all the data.
                        messageData = [tempData mutableCopy];
                        [messagesList reloadData];
                    }
                    
                } else {
                    
                    // Inbox data can just be copied as we
                    // are in the Archived table view mode.
                    messageData = [tempData mutableCopy];
                    
                    // Check if we currently have any data on display.
                    
                    if ([messageDataArchived count] > 0) {
                        
                        // Create the new objects array.
                        NSMutableArray *newDataObjects = [[NSMutableArray alloc] init];
                        
                        // Loop through the downloaded data and add
                        // any new objects to the current data array.
                        
                        for (NSUInteger newDataLoop = 0; newDataLoop < [tempDataArchived count]; newDataLoop++) {
                            
                            // Create the new data check.
                            BOOL addDataCheck = YES;
                            
                            // Get the new data object.
                            ThreadDataObject *data = (ThreadDataObject *)[tempDataArchived[newDataLoop] objectAtIndex:0];
                            
                            // Loop through the current data array and check
                            // if there are any copies of the downloaded data.
                            
                            for (NSUInteger currentDataLoop = 0; currentDataLoop < [messageDataArchived count]; currentDataLoop++) {
                                
                                // Get the current message data object.
                                ThreadDataObject *currentData = [messageDataArchived[currentDataLoop] objectAtIndex:0];
                                
                                // Check if the data already exists.
                                
                                if ([[[data threadObject] objectId] isEqualToString:[[currentData threadObject] objectId]]) {
                                    
                                    // Check if the new data contains
                                    // a message preview data object.
                                    
                                    if ([data latestMessage] != nil) {
                                        
                                        // Check if the current data contains
                                        // a message preview data object.
                                        
                                        if ([currentData latestMessage] != nil) {
                                            
                                            // Check if the new and current message
                                            // preview objects are the same or not.
                                            
                                            if ([[[data latestMessage] objectId] isEqualToString:[[currentData latestMessage] objectId]]) {
                                                
                                                // No new message preview objects have been
                                                // made however an existing one has been updated.
                                                
                                                if ([[data unreadCount] intValue] != [[currentData unreadCount] intValue]) {
                                                    [self refreshListCell:currentDataLoop :tempDataArchived[newDataLoop] :NO];
                                                }
                                                
                                            } else {
                                                [self refreshListCell:currentDataLoop :tempDataArchived[newDataLoop] :NO];
                                            }
                                            
                                        } else {
                                            [self refreshListCell:currentDataLoop :tempDataArchived[newDataLoop] :NO];
                                        }
                                    } else {
                                        
                                        // Check if the current data contains
                                        // a message preview data object.
                                        
                                        if ([currentData latestMessage] != nil) {
                                            [self refreshListCell:currentDataLoop :tempDataArchived[newDataLoop] :NO];
                                        }
                                    }
                                    
                                    // We are not adding new additional data.
                                    addDataCheck = NO;
                                    break;
                                }
                            }
                            
                            // Add the downloaded data if it does
                            // not exist in the current data array.
                            
                            if (addDataCheck == YES) {
                                [newDataObjects insertObject:tempDataArchived[newDataLoop] atIndex:0];
                            }
                        }
                        
                        // Get the size of the new data array.
                        NSUInteger newSize = [newDataObjects count];
                        
                        // Check if there are any new data objects.
                        
                        if (newSize > 0) {
                            
                            // Create the table view index array.
                            NSMutableArray *indexes = [[NSMutableArray alloc] init];
                            
                            // Create the new NSIndexPath objects.
                            
                            for (NSUInteger loop = 1; loop < (newSize + 1); loop++) {
                                [indexes addObject:[NSIndexPath indexPathForRow:(([messageDataArchived count] - 1) + loop) inSection:0]];
                            }
                            
                            // Add the new data to the current array.
                            [messageDataArchived addObjectsFromArray:newDataObjects];
                            
                            // Add the new thread cells to the table view.
                            [messagesList insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
                        }
                        
                    } else {
                        
                        // Reload all the data.
                        messageDataArchived = [tempDataArchived mutableCopy];
                        [messagesList reloadData];
                    }
                }
            }
        }
        
        // Show/hide the no data label depending
        // on the number of message threads.
        [self updateNoDataLabel];
    }];
}

-(void)getPreviewForThread:(PFObject *)thread :(NSString *)otherUser :(threadCompletion)dataBlock {
    
    // Get the message type.
    NSString *messageType = [thread valueForKey:@"typeData"];
    
    // Check the message type and create the
    // appropriate preview description string.
    
    if ([messageType isEqualToString:@"Text"]) {
        dataBlock([thread valueForKey:@"textData"]);
    } else {
        
        // Create the name start string.
        NSString *startString = nil;
        
        // Check who sent the latest message.
        
        if ([[(PFUser *)[thread valueForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
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

-(void)refreshListCell:(NSInteger)row :(id)newObject :(BOOL)dataMode {
    
    // Update the correct data array.
    
    if (dataMode == YES) {
        [messageData replaceObjectAtIndex:row withObject:newObject];
    } else {
        [messageDataArchived replaceObjectAtIndex:row withObject:newObject];
    }
    
    // Reload the specific table view cell.
    [messagesList reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(NSString *)createDateString:(PFObject *)data {
    
    // Create the input date object.
    NSDate *inputDate = [data createdAt];
    
    // Calculate the difference between the dates.
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:inputDate toDate:[NSDate date] options:0];
    
    // Create the date string.
    NSString *dateString = nil;
    
    // Set the date string depending on the time between
    // now and when the private thread was last updated.
    
    if ([components day] > 7) {
        
        // Get the date and time data.
        NSDateComponents *dateComponent = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:inputDate];
        
        // Set the date string.
        dateString = [NSString stringWithFormat:@"%02ld/%02ld/%ld", (long)[dateComponent month], (long)[dateComponent day], (long)[dateComponent year]];
        
    } else {
        
        // Set the day or the hour:minute string depending on
        // how many days ago the thread was last updated.
        
        if ([components day] >= 1) {
            
            // Create the data formatter object.
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            
            // Set the date string.
            dateString = [dateFormatter stringFromDate:inputDate];
            
        } else {
            
            // Get the time data.
            NSDateComponents *time = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:inputDate];
            
            // Check the current hour and create
            // a 12 hour format time string.
            
            if (([time hour] <= 23) && ([time hour] >= 12)) {
                
                // Convert the hour to single digit format.
                
                if ([time hour] != 12) {
                    dateString = [NSString stringWithFormat:@"%ld:%02ld", (long)([time hour] - 12), (long)[time minute]];
                }
                
                else {
                    dateString = [NSString stringWithFormat:@"%ld:%02ld", (long)[time hour], (long)[time minute]];
                }
                
                // Display the time - PM format.
                dateString = [NSString stringWithFormat:@"%@ PM", dateString];
            }
            
            else {
                
                // Display the time - AM format.
                dateString = [NSString stringWithFormat:@"%ld:%02ld", (long)[time hour], (long)[time minute]];
                dateString = [NSString stringWithFormat:@"%@ AM", dateString];
            }
        }
    }
    
    return dateString;
}

/// UI METHODS ///

-(void)updateNoDataLabel {
    
    // Show or hide the no data label depending
    // on the current data array and control mode.
    
    if (messageControl.selectedSegmentIndex == 0) {
        [noDataLabel setAlpha:([messageData count] > 0 ? 0.0 : 1.0)];
    } else {
        [noDataLabel setAlpha:([messageDataArchived count] > 0 ? 0.0 : 1.0)];
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
        [self openExistingMessageThread:[(ThreadDataObject *)[messageData[indexPath.row] objectAtIndex:0] threadObject]];
    } else {
        [self openExistingMessageThread:[(ThreadDataObject *)[messageDataArchived[indexPath.row] objectAtIndex:0] threadObject]];
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
        [cell.profilePicture setAlpha:1.0];
        [cell.titleLabel setAlpha:1.0];
        [cell.descriptionLabel setAlpha:1.0];
        [cell.dateLabel setAlpha:1.0];
        
        // Create the current table view thread data object.
        PFObject *data = nil;
        
        // Create the current message preview data.
        PFObject *messagePreviewData = nil;
        
        // Create the current message unread count.
        NSNumber *messageUnreadCount;
        
        // Create the current data object user.
        NSString *userCheck = nil;
        
        if (messageControl.selectedSegmentIndex == 0) {
            data = [(ThreadDataObject *)[messageData[indexPath.row] objectAtIndex:0] threadObject];
            messagePreviewData = [(ThreadDataObject *)[messageData[indexPath.row] objectAtIndex:0] latestMessage];
            messageUnreadCount = [(ThreadDataObject *)[messageData[indexPath.row] objectAtIndex:0] unreadCount];
            userCheck = [messageData[indexPath.row] objectAtIndex:1];
        } else {
            data = [(ThreadDataObject *)[messageDataArchived[indexPath.row] objectAtIndex:0] threadObject];
            messagePreviewData = [(ThreadDataObject *)[messageDataArchived[indexPath.row] objectAtIndex:0] latestMessage];
            messageUnreadCount = [(ThreadDataObject *)[messageDataArchived[indexPath.row] objectAtIndex:0] unreadCount];
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
        
        // Set the cell data label.
        
        if (messagePreviewData == nil) {
            [cell.dateLabel setText:[self createDateString:data]];
        } else {
            [cell.dateLabel setText:[self createDateString:messagePreviewData]];
        }
        
        // Check the thread message unread count.
        
        if ([messageUnreadCount intValue] > 0) {
            
            // Create the unread messages label.
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 28, 22)];
            [label setText:[NSString stringWithFormat:@"%d", [messageUnreadCount intValue]]];
            [label setNumberOfLines:1];
            [label setAdjustsFontSizeToFitWidth:YES];
            [label setClipsToBounds:YES];
            [[label layer] setCornerRadius:12];
            [label setBackgroundColor:[UIColor redColor]];
            [label setTextColor:[UIColor whiteColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [cell setAccessoryView:label];
            
        } else {
            [cell setAccessoryView:nil];
        }
        
        // Get the other user's profile data.
        [self getUserCachedData:userID :^(NSString *username, UIImage *picture) {
            
            if (picture == nil) {
                [cell.profilePicture setImage:[UIImage imageNamed:@"default_profile_pic.png"]];
            } else {
                [cell.profilePicture setImage:picture];
            }
            
            if (messagePreviewData == nil) {
                [cell.descriptionLabel setText:@"-"];
            } else {
                
                // Get the latest message of the thread.
                [self getPreviewForThread:messagePreviewData :username :^(NSString *preview) {
                    
                    if (preview == nil) {
                        [cell.descriptionLabel setText:@"-"];
                    } else {
                        [cell.descriptionLabel setText:preview];
                    }
                }];
            }
            
            [cell.titleLabel setText:username];
        }];
        
    } else {
        
        // Hide all the main views.
        [cell.profilePicture setAlpha:0.0];
        [cell.titleLabel setAlpha:0.0];
        [cell.descriptionLabel setAlpha:0.0];
        [cell.dateLabel setAlpha:0.0];
        
        // Hide the cell accessory view.
        [cell setAccessoryView:nil];
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
    return 76;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (messageControl.selectedSegmentIndex == 0) {
        return [messageData count];
    } else {
        return [messageDataArchived count];
    }
}

/// OTHER METHODS ///

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
