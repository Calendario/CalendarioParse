//
//  PrivateMessagesHelper.m
//  Calendario
//
//  Created by Daniel Sadjadian on 31/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import "PrivateMessagesHelper.h"
#import "ThreadDataObject.h"

@implementation PrivateMessagesHelper

/// DATA METHODS ///

-(void)getTotalNumberOfUnreadMessages:(countCompletion)dataBlock {
    
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
            
            // Check if there are any message threads.
            
            if ([objects count] > 0) {
                
                // Create the thread IDs array.
                NSMutableArray *threadIDs = [[NSMutableArray alloc] init];
                
                // Loop through the threads and store their objectIDs.
                
                for (NSUInteger loop = 0; loop < [objects count]; loop++) {
                    [threadIDs addObject:[(PFObject *)objects[loop] objectId]];
                }
                
                // Create the message data query.
                PFQuery *messageQuery = [PFQuery queryWithClassName:@"privateMessagesMedia"];
                [messageQuery whereKey:@"threadID" containedIn:threadIDs];
                
                // Get all the messages for the threads.
                [messageQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    
                    if (error == nil) {
                        
                        // Check if there are any message.
                        
                        if ([objects count] > 0) {
                            
                            // Create the unread message count.
                            int unreadMessages = 0;
                            
                            // Loop through the messages and find the unread
                            // ones sent to the logged in user by antoher user.
                            
                            for (NSUInteger loop = 0; loop < [objects count]; loop ++) {
                                
                                // Get the current loop object.
                                PFObject *loopData = [objects objectAtIndex:loop];
                                
                                // Ensure that the message is not
                                // authored by the logged in user.
                                
                                if (![[(PFUser *)[loopData valueForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                                    
                                    // Check the message state and
                                    // increase the count accordingly.
                                    
                                    if ([[loopData valueForKey:@"currentStatus"] boolValue] == NO) {
                                        unreadMessages = (unreadMessages + 1);
                                    }
                                }
                            }
                            
                            dataBlock([NSNumber numberWithInt:unreadMessages]);
                            
                        } else {
                            dataBlock([NSNumber numberWithInt:0]);
                        }
                        
                    } else {
                        dataBlock([NSNumber numberWithInt:0]);
                    }
                }];
                
            } else {
                dataBlock([NSNumber numberWithInt:0]);
            }
            
        } else {
            dataBlock([NSNumber numberWithInt:0]);
        }
    }];
}

-(void)getUserThreadsWithInfo:(threadDataCompletion)dataBlock {
    
    // Create the thread data array.
    __block NSMutableArray *threadAllData = [[NSMutableArray alloc] init];
    
    // Setup the first thread data query.
    PFQuery *threadQueryA = [PFQuery queryWithClassName:@"privateMessageThreads"];
    [threadQueryA whereKey:@"userA" equalTo:[PFUser currentUser]];
    
    // Setup the second thread data query.
    PFQuery *threadQueryB = [PFQuery queryWithClassName:@"privateMessageThreads"];
    [threadQueryB whereKey:@"userB" equalTo:[PFUser currentUser]];
    
    // Create the overall message query (userA OR userB).
    PFQuery *messageQuery = [PFQuery orQueryWithSubqueries:@[threadQueryA, threadQueryB]];
    
    // Run the message thread query.
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable threadAllObjects, NSError * _Nullable error) {
        
        if (error == nil) {
            
            // Check if there are any message threads.
            
            if ([threadAllObjects count] > 0) {
                
                // Create the thread IDs array.
                NSMutableArray *threadIDs = [[NSMutableArray alloc] init];
                
                // Loop through the threads and store their objectIDs.
                
                for (NSUInteger loop = 0; loop < [threadAllObjects count]; loop++) {
                    [threadIDs addObject:[(PFObject *)threadAllObjects[loop] objectId]];
                }
                
                // Create the message data query.
                PFQuery *messageQuery = [PFQuery queryWithClassName:@"privateMessagesMedia"];
                [messageQuery whereKey:@"threadID" containedIn:threadIDs];
                [messageQuery orderByDescending:@"createdAt"];
                
                // Get all the messages for the threads.
                [messageQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    
                    if (error == nil) {
                        
                        // Check if the thread contains any objects.
                        
                        if ([objects count] > 0) {
                            
                            // Loop through the thread data and load
                            // the message previews and unread counts.
                            
                            for (NSUInteger loop = 0; loop < [threadAllObjects count]; loop++) {
                                
                                // Create the loop unread count.
                                int loopUnreadCount = 0;
                                
                                // Create the latest data added check.
                                BOOL latestDataAdded = NO;
                                
                                // Get the current thread objects.
                                PFObject *threadObject = [threadAllObjects objectAtIndex:loop];
                                
                                // Create the thread data object.
                                ThreadDataObject *arrayObject = [[ThreadDataObject alloc] init];
                                
                                // Set the current thread object data.
                                [arrayObject setThreadObject:threadObject];
                                
                                // Loop through the message data and store the
                                // latest message and unread count for each thread.
                                
                                for (NSUInteger messagesLoop = 0; messagesLoop < [objects count]; messagesLoop++) {
                                    
                                    // Get the current message object.
                                    PFObject *messageObject = [objects objectAtIndex:messagesLoop];
                                    
                                    // Check if we have found the latest message
                                    // for the current loop thread object id string.
                                    
                                    if ([[threadObject objectId] isEqualToString:[messageObject valueForKey:@"threadID"]]) {
                                        
                                        // Only store the latest message object
                                        // for the thread table view cell preview.
                                        
                                        if (latestDataAdded == NO) {
                                            [arrayObject setLatestMessage:messageObject];
                                            latestDataAdded = YES;
                                        }
                                        
                                        // Increase the unread messages count if the
                                        // current message object is set to un-read.
                                        
                                        if ((![[(PFUser *)[messageObject valueForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) && ([[messageObject valueForKey:@"currentStatus"] boolValue] == NO)) {
                                            loopUnreadCount = (loopUnreadCount + 1);
                                        }
                                    }
                                }
                                
                                // Set the unread message count data.
                                [arrayObject setUnreadCount:[NSNumber numberWithInt:loopUnreadCount]];
                                
                                // Store the new formed data in the all data array.
                                [threadAllData addObject:arrayObject];
                            }
                            
                            dataBlock(threadAllData);
                            
                        } else {
                            dataBlock([self setThreadDataWithoutExtraData:threadAllObjects]);
                        }
                        
                    } else {
                        dataBlock([self setThreadDataWithoutExtraData:threadAllObjects]);
                    }
                }];
                
            } else {
                dataBlock(nil);
            }
            
        } else {
            dataBlock(nil);
        }
    }];
}

-(NSMutableArray *)setThreadDataWithoutExtraData:(NSArray *)data {
    
    // Create the thread data array.
    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
    
    // Loop through the input objects array
    // and create default thread objects with
    // no message data and 0 unread counts.
    
    for (NSUInteger loop = 0; loop < [data count]; loop++) {
        
        // Create the thread data object.
        ThreadDataObject *arrayObject = [[ThreadDataObject alloc] init];
        
        // Set the default thread data.
        [arrayObject setThreadObject:data[loop]];
        [arrayObject setLatestMessage:nil];
        [arrayObject setUnreadCount:[NSNumber numberWithInt:0]];
        
        // Add the data to the final array.
        [finalArray addObject:arrayObject];
    }
    
    return finalArray;
}

@end
