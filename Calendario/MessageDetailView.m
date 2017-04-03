//
//  MessageDetailView.m
//  Calendario
//
//  Created by Daniel Sadjadian on 22/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import "MessageDetailView.h"
#import "Calendario-Swift.h"
#import "IQAudioRecorderViewController.h"

@interface MessageDetailView () <IQAudioRecorderViewControllerDelegate> {
    
    // New message data object.
    PFObject *newMessage;
    
    // Video data object.
    NSData *videoData;
}

@end

@implementation MessageDetailView
@synthesize passedInUser;
@synthesize passedInThread;

/// BUTTONS ///

-(IBAction)done:(id)sender {
    
    // Hide the on screen keyboard.
    [self dismissKeyboard];
    
    // Close the current view.
    [self dismissViewControllerAnimated:YES completion:^{
        [reloadTimer invalidate];
    }];
}

-(IBAction)send:(id)sender {
    
    // Trim the chat string text.
    NSString *chatString = [messageField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Check if the chat data is valid or not
    // before performing the upload request.
    
    if (([chatString length] > 0) && (messageField.text != nil)) {
        
        // Hide the on screen keyboard.
        [self dismissKeyboard];
        
        // Send the text message.
        [self sendMessage:@"Text" :messageField.text];
    }
}

-(IBAction)addAttachment:(id)sender {
    
    // Hide the on screen keyboard.
    [self dismissKeyboard];
    
    // Create the info alert.
    UIAlertController *alert;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        alert = [UIAlertController alertControllerWithTitle:@"Send File" message:@"Select the message type you would like to share." preferredStyle:UIAlertControllerStyleAlert];
    } else {
        alert = [UIAlertController alertControllerWithTitle:@"Send File" message:@"Select the message type you would like to share." preferredStyle:UIAlertControllerStyleActionSheet];
    }
    
    // Create the alert actions.
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera (Photo/Video)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Check to see if the users iOS device
        // has a camera installed and then use it.
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            // Check the camera/microphone authorisation status.
            AVAuthorizationStatus statusCamera = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            AVAuthorizationStatus statusMicrophone = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
            
            // Check the status responce and act acoordingly.
            
            if ((statusCamera == AVAuthorizationStatusAuthorized) && (statusMicrophone == AVAuthorizationStatusAuthorized)) {
                
                // Access has been granted.
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
                
                // Present the camera image view.
                [self presentViewController:picker animated:YES completion:nil];
            }
            
            else if ((statusCamera == AVAuthorizationStatusDenied) || (statusMicrophone == AVAuthorizationStatusDenied)) {
                
                // Access has been denied.
                [self displayAlert:@"Error" :@"Calendario has not been granted access to the camera and/or microphone. Please ensure you have granted access in the Settings app and try again."];
            }
            
            else if ((statusCamera == AVAuthorizationStatusRestricted) || (statusMicrophone == AVAuthorizationStatusRestricted)) {
                
                // Access has been restricted.
                [self displayAlert:@"Error" :@"Calendario has not been granted access to the camera and/or microphone. Please ensure you have granted access in the Settings app and try again."];
            }
            
            else if ((statusCamera == AVAuthorizationStatusNotDetermined) || ((statusMicrophone == AVAuthorizationStatusNotDetermined))) {
                
                // Access has not been determined - Camera.
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted_video) {
                    
                    if (granted_video) {
                        
                        // Access has not been determined - Microphone.
                        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted_audio) {
                            
                            if (granted_audio) {
                                
                                // Access has been granted.
                                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                picker.delegate = self;
                                picker.allowsEditing = YES;
                                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                picker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
                                
                                // Present the camera image view.
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    [self presentViewController:picker animated:YES completion:nil];
                                });
                            }
                            
                            else {
                                
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                    
                                    // Access has been denied.
                                    [self displayAlert:@"Error" :@"Calendario has not been granted access to the microphone. Please ensure you have granted access in the Settings app and try again."];
                                });
                            }
                        }];
                    }
                    
                    else {
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            
                            // Access has been denied.
                            [self displayAlert:@"Error" :@"Calendario has not been granted access to the camera. Please ensure you have granted access in the Settings app and try again."];
                        });
                    }
                }];
            }
        }
        
        else {
            
            // Display the camera error alert.
            [self displayAlert:@"Error" :@"You can not take a photo/video because your device does not have a camera."];
        }
    }];
    
    UIAlertAction *library = [UIAlertAction actionWithTitle:@"Library (Photo/Video)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            
            // Request photo library access.
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            
            // Check the status responce and act acoordingly.
            
            if (status == PHAuthorizationStatusAuthorized) {
                
                // Access has been granted.
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                picker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
                
                // Display the image picker view.
                [self presentViewController:picker animated:YES completion:nil];
            }
            
            else if (status == PHAuthorizationStatusDenied) {
                
                // Access has been denied.
                [self displayAlert:@"Error" :@"Calendario is unable to access your photo library. Please ensure you have granted access in the Settings app and try again."];
            }
            
            else if (status == PHAuthorizationStatusNotDetermined) {
                
                // Access has not been determined.
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    
                    if (status == PHAuthorizationStatusAuthorized) {
                        
                        // Access has been granted.
                        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                        picker.delegate = self;
                        picker.allowsEditing = YES;
                        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        picker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
                        
                        // Display the image picker view.
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self presentViewController:picker animated:YES completion:nil];
                        });
                    }
                    
                    else {
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            
                            // Access has been denied.
                            [self displayAlert:@"Error" :@"Calendario is unable to access your photo library. Please ensure you have granted access in the Settings app and try again."];
                        });
                    }
                }];
            }
            
            else if (status == PHAuthorizationStatusRestricted) {
                
                // Restricted access - normally won't happen.
                [self displayAlert:@"Error" :@"Calendario is unable to access your photo library. Please ensure you have granted access in the Settings app and try again."];
            }
        }
        
        else {
            
            // Display the photo library error alert.
            [self displayAlert:@"Error" :@"Calendario is unable to access your photo library. Please ensure you have granted access in the Settings app and try again."];
        }
    }];
    
    UIAlertAction *map = [UIAlertAction actionWithTitle:@"Location" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Open the location selector view.
        UIStoryboard *storyFile = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *screen = [storyFile instantiateViewControllerWithIdentifier:@"LocationVC"];
        [self presentViewController:screen animated:YES completion:nil];
    }];
    
    UIAlertAction *currentLocation = [UIAlertAction actionWithTitle:@"Current Location" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Check if current location data is available.
        [self checkCurrentLocation:^(BOOL dataCheck) {
            
            // Check if current location data
            // authorization has been granted.
            
            if (dataCheck == YES) {
                
                // Hide the on screen keyboard.
                [self dismissKeyboard];
                
                // Send the location message.
                [self sendMessage:@"Map" :[PFGeoPoint geoPointWithLatitude:locationManager.location.coordinate.latitude longitude:locationManager.location.coordinate.longitude]];
            }
        }];
    }];
    
    UIAlertAction *audio = [UIAlertAction actionWithTitle:@"Voice message" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Check the microphone authorisation status.
        AVAuthorizationStatus statusMicrophone = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        
        // Check the status responce and act acoordingly.
        
        if (statusMicrophone == AVAuthorizationStatusAuthorized) {
            
            // Open the audio recorder view.
            [self openAudioRecorder];
        }
        
        else if (statusMicrophone == AVAuthorizationStatusDenied) {
            
            // Access has been denied.
            [self displayAlert:@"Error" :@"Calendario has not been granted access to the microphone. Please ensure you have granted access in the Settings app and try again."];
        }
        
        else if (statusMicrophone == AVAuthorizationStatusRestricted) {
            
            // Access has been restricted.
            [self displayAlert:@"Error" :@"Calendario has not been granted access to the microphone. Please ensure you have granted access in the Settings app and try again."];
        }
        
        else if (statusMicrophone == AVAuthorizationStatusNotDetermined) {
            
            // Access has not been determined - Microphone.
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted_audio) {
                
                if (granted_audio) {
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        // Open the audio recorder view.
                        [self openAudioRecorder];
                    });
                }
                
                else {
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        // Access has been denied.
                        [self displayAlert:@"Error" :@"Calendario has not been granted access to the microphone. Please ensure you have granted access in the Settings app and try again."];
                    });
                }
            }];
        }
    }];
    
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    
    // Add the action and present the alert.
    [alert addAction:camera];
    [alert addAction:library];
    [alert addAction:map];
    [alert addAction:currentLocation];
    [alert addAction:audio];
    [alert addAction:dismiss];
    [self presentViewController:alert animated:YES completion:nil];
}

/// VIEW DID LOAD ///

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setup the audio session and the
    // change audio method notification.
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Setup the location manager class.
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager requestWhenInUseAuthorization];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [locationManager startUpdatingLocation];
    
    // Curve the egdes of the record/send button views.
    [[sendButton layer] setCornerRadius:4.0];
    
    // Ensure the comment container does not block the table view (and scroll bar).
    [chatList setContentInset:UIEdgeInsetsMake(0, 0, commentContainer.frame.size.height, 0)];
    [chatList setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, commentContainer.frame.size.height, 0)];
    
    // Hide the no data label by default.
    [noDataLabel setAlpha:0.0];
    
    // Get the device screen size.
    CGSize result = [[UIScreen mainScreen] bounds].size;
    
    // Set the cell width based on the screen size.
    
    if (result.height <= 480) {
        
        // 3.5 inch display - iPhone 4S & below.
        textCellWidth = 205;
    }
    
    else if (result.height == 568) {
        
        // 4 inch display - iPhone 5/5s.
        textCellWidth = 205;
    }
    
    else if (result.height == 667) {
        
        // 4.7 inch display - iPhone 6.
        textCellWidth = 249;
    }
    
    else if (result.height >= 736) {
        
        // 5.5 inch display - iPhone 6 Plus.
        textCellWidth = 288;
    }
    
    // Load all the thread messages.
    [self loadAllMessages];
    
    // Keep checking for new thread messages (every 1.5 seconds).
    reloadTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(loadAllMessages) userInfo:nil repeats:YES];
}

/// VIEW WILL APPEAR ///

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set the received location notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationReceived:) name:@"PRIVATE-DM-LOCATION" object:nil];
    
    // Set the keyboard appeared notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // Set the audio route changed notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
}

/// VIEW WILL DISSAPPEAR ///

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Remove the notification observers so that
    // we do not get any accidental method calls.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PRIVATE-DM-LOCATION" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

/// DATA METHODS ///

-(void)loadAllMessages {
    
    // Check if a thread object has been passed in.
    
    if (passedInThread != nil) {
        
        // Setup the messages media data query.
        PFQuery *messageQuery = [PFQuery queryWithClassName:@"privateMessagesMedia"];
        [messageQuery whereKey:@"threadID" equalTo:[passedInThread objectId]];
        
        // Run the message media query.
        [messageQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            if (error == nil) {
                
                // Check if there are any messages in the thread.
                
                if ([objects count] > 0) {
                    
                    // Check if we are currently display any messages.
                    
                    if ([chatMessages count] > 0) {
                        
                        // Create the new objects array.
                        NSMutableArray *newDataObjects = [[NSMutableArray alloc] init];
                        
                        // Loop through the current message data
                        // and check if there are any new messages.
                        
                        for (NSUInteger newDataLoop = 0; newDataLoop < [objects count]; newDataLoop++) {
                            
                            // Add new data check.
                            BOOL addDataCheck = YES;
                            
                            // Get the current data object.
                            PFObject *newData = [objects objectAtIndex:newDataLoop];
                            
                            // Loop through the current message array and
                            // check if the new data is already present.
                            
                            for (NSUInteger chatLoop = 0; chatLoop < [chatMessages count]; chatLoop++) {
                                
                                // If the data is already present then do
                                // not add it to the messages table view.
                                
                                if ([[(PFObject *)chatMessages[chatLoop] objectId] isEqualToString:[newData objectId]]) {
                                    addDataCheck = NO;
                                    break;
                                }
                            }
                            
                            // Check if we can the new data in.
                            
                            if (addDataCheck == YES) {
                                [newDataObjects insertObject:newData atIndex:0];
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
                                [indexes addObject:[NSIndexPath indexPathForRow:(([chatMessages count] - 1) + loop) inSection:0]];
                            }
                            
                            // Add the new data to the current array.
                            [chatMessages addObjectsFromArray:newDataObjects];
                            
                            // Add the new thread cells to the table view.
                            [chatList insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
                            
                            // Scroll to the bottom of the table view.
                            [self scrollToBottomOfList:YES];
                        }
                        
                    } else {
                        
                        // Reload the entire thread data.
                        chatMessages = [objects mutableCopy];
                        [chatList reloadData];
                        [self scrollToBottomOfList:NO];
                    }
                }
            }
            
            // Show/hide the no data label
            // based on the number of messages.
            [self updateNoDataLabel];
        }];
        
    } else {
        
        // Show/hide the no data label
        // based on the number of messages.
        [self updateNoDataLabel];
    }
}

-(void)sendMessage:(NSString *)messageType :(id)data {
    
    // Temporarily disable access to the bottom view.
    [self setBottomContainerAccess:NO];
    
    // Create the "has the logged in user
    // blocked the passed in user" query.
    PFQuery *blockQueryOne = [PFQuery queryWithClassName:@"blockUser"];
    [blockQueryOne whereKey:@"userBlock" equalTo:passedInUser];
    [blockQueryOne whereKey:@"userBlocking" equalTo:[PFUser currentUser]];
    
    // Run the first user block query.
    [blockQueryOne findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (error == nil) {
            
            if ([objects count] > 0) {
                
                // Re-enable access to the bottom views.
                [self setBottomContainerAccess:YES];
                
                // Display the user blocked error.
                [self displayAlert:@"Error" :@"Please unblock the user, in order to send him/her a private message."];
                
            } else {
                
                // Create the "has the passed in user
                // blocked the logged in user" query.
                PFQuery *blockQueryTwo = [PFQuery queryWithClassName:@"blockUser"];
                [blockQueryTwo whereKey:@"userBlock" equalTo:[PFUser currentUser]];
                [blockQueryTwo whereKey:@"userBlocking" equalTo:passedInUser];
                
                // Run the second user block query.
                [blockQueryTwo findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    
                    if (error == nil) {
                        
                        if ([objects count] > 0) {
                            
                            // Re-enable access to the bottom views.
                            [self setBottomContainerAccess:YES];
                            
                            // Display the user blocked error.
                            [self displayAlert:@"Error" :@"The user you are trying to message has blocked you."];
                            
                        } else {
                            
                            // Check if the thread data is available.
                            
                            if (passedInThread == nil) {
                                
                                // Setup the first thread data query.
                                PFQuery *threadQueryA = [PFQuery queryWithClassName:@"privateMessageThreads"];
                                [threadQueryA whereKey:@"userA" equalTo:[PFUser currentUser]];
                                [threadQueryA whereKey:@"userB" equalTo:passedInUser];
                                
                                // Setup the second thread data query.
                                PFQuery *threadQueryB = [PFQuery queryWithClassName:@"privateMessageThreads"];
                                [threadQueryB whereKey:@"userA" equalTo:passedInUser];
                                [threadQueryB whereKey:@"userB" equalTo:[PFUser currentUser]];
                                
                                // Create the overall message query (userA OR userB).
                                PFQuery *messageQuery = [PFQuery orQueryWithSubqueries:@[threadQueryA, threadQueryB]];
                                
                                // Run the message thread query.
                                [messageQuery getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                                    
                                    if (error == nil) {
                                        
                                        // Check if there is an existing thread.
                                        
                                        if (object == nil) {
                                            
                                            // Upload the private message data.
                                            [self uploadMessageData:messageType :nil :data];
                                            
                                        } else {
                                            
                                            // Upload the private message data.
                                            [self uploadMessageData:messageType :object :data];
                                        }
                                        
                                    } else {
                                        
                                        // Upload the private message data.
                                        [self uploadMessageData:messageType :nil :data];
                                    }
                                }];
                                
                            } else {
                                
                                // Upload the private message data.
                                [self uploadMessageData:messageType :passedInThread :data];
                            }
                        }
                        
                    } else {
                        
                        // Re-enable access to the bottom views.
                        [self setBottomContainerAccess:YES];
                    }
                }];
            }
            
        } else {
            
            // Re-enable access to the bottom views.
            [self setBottomContainerAccess:YES];
        }
    }];
}

-(void)uploadMessageData:(NSString *)messageType :(PFObject *)thread :(id)data {
    
    // Create a new thread is an existing
    // one is not present for the two users.
    
    if (thread == nil) {
        
        // Create the new thread object.
        PFObject *newThread = [PFObject objectWithClassName:@"privateMessageThreads"];
        newThread[@"userA"] = [PFUser currentUser];
        newThread[@"userB"] = passedInUser;
        newThread[@"userAHidden"] = @NO;
        newThread[@"userBHidden"] = @NO;
        
        // Upload the new thread data.
        [newThread saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if ((succeeded) && (error == nil)) {
                
                // Update the passed in thread object.
                passedInThread = newThread;
                
                // Create the new message object.
                newMessage = [PFObject objectWithClassName:@"privateMessagesMedia"];
                newMessage[@"threadID"] = [passedInThread objectId];
                newMessage[@"fromUser"] = [PFUser currentUser];
                newMessage[@"typeData"] = messageType;
                newMessage[@"currentStatus"] = @NO;
                
                // Set the query info data.
                [self setMessageQueryData:messageType :data];
                
                // Upload the new message data.
                [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if ((succeeded) && (error == nil)) {
                        [messageField setText:nil];
                        [self loadAllMessages];
                    }
                    
                    // Re-enable access to the bottom views.
                    [self setBottomContainerAccess:YES];
                }];
            } else {
                
                // Re-enable access to the bottom views.
                [self setBottomContainerAccess:YES];
            }
        }];
        
    } else {
        
        // Check if both users have the message in their
        // inboxes rather than their archived messages.
        
        if (([[thread valueForKey:@"userAHidden"] boolValue] == YES) || ([[thread valueForKey:@"userBHidden"] boolValue] == YES)) {
            
            // Ensure both users can see the thread.
            thread[@"userAHidden"] = @NO;
            thread[@"userBHidden"] = @NO;
            
            // Upload the new thread data.
            [thread saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if ((succeeded) && (error == nil)) {
                    
                    // Update the passed in thread object.
                    passedInThread = thread;
                    
                    // Create the new message object.
                    newMessage = [PFObject objectWithClassName:@"privateMessagesMedia"];
                    newMessage[@"threadID"] = [passedInThread objectId];
                    newMessage[@"fromUser"] = [PFUser currentUser];
                    newMessage[@"typeData"] = messageType;
                    newMessage[@"currentStatus"] = @NO;
                    
                    // Set the query info data.
                    [self setMessageQueryData:messageType :data];
                    
                    // Upload the new message data.
                    [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if ((succeeded) && (error == nil)) {
                            [messageField setText:nil];
                            [self loadAllMessages];
                        }
                        
                        // Re-enable access to the bottom views.
                        [self setBottomContainerAccess:YES];
                    }];
                } else {
                    
                    // Re-enable access to the bottom views.
                    [self setBottomContainerAccess:YES];
                }
            }];
            
        } else {
            
            // Create the new message object.
            newMessage = [PFObject objectWithClassName:@"privateMessagesMedia"];
            newMessage[@"threadID"] = [thread objectId];
            newMessage[@"fromUser"] = [PFUser currentUser];
            newMessage[@"typeData"] = messageType;
            newMessage[@"currentStatus"] = @NO;
            
            // Set the query info data.
            [self setMessageQueryData:messageType :data];
            
            // Upload the new message data.
            [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if ((succeeded) && (error == nil)) {
                    [messageField setText:nil];
                    [self loadAllMessages];
                }
                
                // Re-enable access to the bottom views.
                [self setBottomContainerAccess:YES];
            }];
        }
    }
}

-(void)setMessageQueryData:(NSString *)messageType :(id)data {
    
    // Set the main message data object.
    
    if ([messageType isEqualToString:@"Text"]) {
        newMessage[@"textData"] = data;
    }
    
    else if ([messageType isEqualToString:@"Photo"]) {
        newMessage[@"photoData"] = [PFFile fileWithData:UIImageJPEGRepresentation(data, 0.5)];
    }
    
    else if ([messageType isEqualToString:@"Map"]) {
        newMessage[@"locationData"] = data;
    }
    
    else if ([messageType isEqualToString:@"Video"]) {
        newMessage[@"photoData"] = [PFFile fileWithData:UIImageJPEGRepresentation(data, 0.5)];
        newMessage[@"videoData"] = [PFFile fileWithData:videoData contentType:@"video/mp4"];
    }
    
    else {
        newMessage[@"audioDurationData"] = (NSArray *)data[0];
        newMessage[@"audioData"] = (NSArray *)data[1];
    }
}

-(void)getProfilePictureCachedData:(NSString *)userID :(pictureCompletion)dataBlock {
    
    // Setup the user cache.
    static NSCache *userCache = nil;
    static dispatch_once_t onceToken;
    
    // Setup the cache object.
    
    dispatch_once(&onceToken, ^{
        userCache = [NSCache new];
    });
    
    // Create the profile picture key.
    NSString *pictureKey = [NSString stringWithFormat:@"PROFILE-PICTURE-%@", userID];
    NSString *usernameKey = [NSString stringWithFormat:@"PROFILE-USERNAME-%@", userID];
    
    // Access the user cache with the unique ID string.
    UIImage *cachedUserPicture = [userCache objectForKey:pictureKey];
    NSString *cachedUsername = [userCache objectForKey:usernameKey];
    
    // Check if the user data has been
    // previously stored in the cache.
    
    if ((cachedUserPicture != nil) && ((cachedUsername != nil))) {
        dataBlock(cachedUserPicture, cachedUsername);
    }
    
    else {
        
        // Load the user profile data.
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" equalTo:userID];
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (error == nil) {
                
                // Get the user data object.
                PFUser *user = (PFUser *)object;
                
                // Download the user profile image.
                PFFile *userImageFile = object[@"profileImage"];
                [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    
                    if (error == nil) {
                        
                        // Set the profile image view.
                        UIImage *image = [UIImage imageWithData:imageData];
                        
                        // Save the user data in the cache.
                        [userCache setObject:image forKey:pictureKey];
                        
                        dataBlock(image, [user username]);
                        
                    } else {
                        dataBlock(nil, [user username]);
                    }
                }];
                
            } else {
                dataBlock(nil, nil);
            }
        }];
    }
}

-(void)getMainPictureCachedData:(PFObject *)data :(pictureCompletion)dataBlock {
    
    // Setup the picture cache.
    static NSCache *pictureCache = nil;
    static dispatch_once_t onceToken;
    
    // Setup the cache object.
    
    dispatch_once(&onceToken, ^{
        pictureCache = [NSCache new];
    });
    
    // Create the main picture key.
    NSString *pictureKey = [NSString stringWithFormat:@"PICTURE-%@-%@", [data valueForKey:@"typeData"], [data objectId]];
    
    // Access the picture cache with the unique ID string.
    UIImage *cachedMainPicture = [pictureCache objectForKey:pictureKey];
    
    // Check if the main picture data has
    // been previously stored in the cache.
    
    if (cachedMainPicture) {
        dataBlock(cachedMainPicture, nil);
    }
    
    else {
        
        // Download the main picture.
        PFFile *userImageFile = [data valueForKey:@"photoData"];
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            
            if (error == nil) {
                
                // Load the main picture data.
                UIImage *image = [UIImage imageWithData:imageData];
                
                // Save the picture data in the cache.
                [pictureCache setObject:image forKey:pictureKey];
                
                dataBlock(image, nil);
                
            } else {
                dataBlock(nil, nil);
            }
        }];
    }
}

-(float)getHeightCachedData:(PFObject *)data {
    
    // Setup the height cache.
    static NSCache *heightCache = nil;
    static dispatch_once_t onceToken;
    
    // Setup the cache object.
    
    dispatch_once(&onceToken, ^{
        heightCache = [NSCache new];
    });
    
    // Create the main height key.
    NSString *heightKey = [NSString stringWithFormat:@"HEIGHT-%@", [data objectId]];
    
    // Access the height cache with the unique ID string.
    NSNumber *cachedHeight = [heightCache objectForKey:heightKey];
    
    // Check if the height data has been
    // previously stored in the cache.
    
    if (cachedHeight) {
        return [cachedHeight floatValue];
    }
    
    else {
        
        // Get the current message data tyoe.
        NSString *messageType = [data valueForKey:@"typeData"];
        
        // Create the cell size value.
        float cellHeight = 0.0;
        
        // Check the message type and calculate the
        // appropriate table view cell height value.
        
        if ([messageType isEqualToString:@"Text"]) {
            
            // Get the full message strings.
            NSString *messageLabel = [NSString stringWithFormat:@"@%@", [data valueForKey:@"textData"]];
            
            // Calculate the message text height.
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
            CGRect rect = [messageLabel boundingRectWithSize:CGSizeMake(textCellWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
            
            // Only return the generated height if
            // it is bigger than the original height.
            
            if (rect.size.height > 31) {
                cellHeight = (30 + rect.size.height + 31);
            }
            
            else {
                cellHeight = 68;
            }
        }
        
        else if ([messageType isEqualToString:@"Audio"]) {
            cellHeight = 103;
        }
        
        else {
            cellHeight = 195;
        }
        
        // Save the cell height data in the cache.
        [heightCache setObject:[NSNumber numberWithFloat:cellHeight] forKey:heightKey];
        
        return cellHeight;
    }
}

-(void)updateMessageStatus:(PFObject *)data {
    
    // Only edit the message statuses of posts not
    // created by you (sent via the other users).
    
    if (![[(PFUser *)[data valueForKey:@"fromUser"] objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        
        // Setup the status cache.
        static NSCache *statusCache = nil;
        static dispatch_once_t onceToken;
        
        // Setup the cache object.
        
        dispatch_once(&onceToken, ^{
            statusCache = [NSCache new];
        });
        
        // Create the main status key.
        NSString *statusKey = [NSString stringWithFormat:@"MESSAGE-STATUS-%@", [data objectId]];
        
        // Access the status cache with the unique ID string.
        NSString *cachedStatus = [statusCache objectForKey:statusKey];
        
        // Check if the status data has been
        // previously stored in the cache.
        
        if (cachedStatus) {
            
            // Check if the status has not been updated yet.
            
            if ([cachedStatus isEqualToString:@"NO"]) {
                
                // Set the message status to read.
                data[@"currentStatus"] = @YES;
                
                // Update the message data object.
                [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [statusCache setObject:@"YES" forKey:statusKey];
                    }
                }];
            }
        }
        
        else {
            
            // Check if the message status is currently
            // in the 'un-read' user message state.
            
            if ([[data valueForKey:@"currentStatus"] boolValue] == NO) {
                
                // Set the message status to read.
                data[@"currentStatus"] = @YES;
                
                // Update the message data object.
                [data saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [statusCache setObject:@"YES" forKey:statusKey];
                    }
                }];
            }
        }
    }
}

-(void)checkCurrentLocation:(locationCheckCompletion)dataBlock {
    
    // Check if the location manager is ready.
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        // Ensure that the user has authorised
        // location data access for the app.
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            
            // Display the denied alert.
            [self displayAlert:@"Error" :@"Calendario does not have permission to access your location information. Please go to Settings and turn on Location Services for this app and then try again."];
        }
        
        else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
            
            // Ensure the location data is valid.
            
            if (locationManager.location != nil) {
                dataBlock(YES);
            }
            
            else {
                
                // Display the location data error.
                [self displayAlert:@"Error" :@"There was an error obtaining the location information. Please ensure that you have enabled location services for this app."];
            }
        }
    }
    
    else {
        
        // Display the location data error.
        [self displayAlert:@"Error" :@"There was an error obtaining the location information. Please ensure that you have enabled location services for this app."];
    }
    
    dataBlock(NO);
}

-(void)locationReceived:(NSNotification *)object {
    
    // Check if the data is valid.
    
    if (object != nil) {
        
        // Get the location data array.
        NSArray *data = (NSArray *)[object object];
        
        // Hide the on screen keyboard.
        [self dismissKeyboard];
        
        // Send the location message.
        [self sendMessage:@"Map" :[PFGeoPoint geoPointWithLatitude:[data[0] doubleValue] longitude:[data[1] doubleValue]]];
    }
}

/// KEYBOARD METHODS ///

-(void)keyboardWillShow:(NSNotification *)object {
    
    // Get the current keyboard height.
    float height = [[[object userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    // Move the comment container above the keyboard.
    [UIView animateWithDuration:0.2 delay:0.0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
        commentContainer.frame = CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height - height - commentContainer.frame.size.height), [[UIScreen mainScreen] bounds].size.width, commentContainer.frame.size.height);
    } completion:nil];
}

-(void)dismissKeyboard {
    
    // Hide the on screen keyboard.
    [messageField resignFirstResponder];
    
    // Move the comment container to the bottom.
    [UIView animateWithDuration:0.2 delay:0.0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
        commentContainer.frame = CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height - commentContainer.frame.size.height), [[UIScreen mainScreen] bounds].size.width, commentContainer.frame.size.height);
    } completion:nil];
}

/// UI METHODS ///

-(void)openAudioRecorder {
    
    // Open the audio recorder view.
    IQAudioRecorderViewController *controller = [[IQAudioRecorderViewController alloc] init];
    [controller setDelegate:self];
    [controller setTitle:@"Voice Message"];
    [controller setMaximumRecordDuration:30];
    [controller setAudioQuality:IQAudioQualityMax];
    [controller setAllowCropping:NO];
    [controller setBarStyle:UIBarStyleBlack];
    [controller setNormalTintColor:[UIColor whiteColor]];
    [controller setHighlightedTintColor:[UIColor whiteColor]];
    [self presentBlurredAudioRecorderViewControllerAnimated:controller];
}

-(void)updateNoDataLabel {
    
    // Show or hide the no data label
    // depending on the number of messages.
    [noDataLabel setAlpha:([chatMessages count] > 0 ? 0.0 : 1.0)];
}

-(void)scrollToBottomOfList:(BOOL)animated {
    
    // Scroll to the bottom of the table view.
    
    if ([chatList contentSize].height > chatList.frame.size.height) {
        [chatList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([chatMessages count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}

-(void)setBottomContainerAccess:(BOOL)check {
    
    // Set interaction access to the container views.
    [attachmentButton setUserInteractionEnabled:check];
    [messageField setUserInteractionEnabled:check];
    [sendButton setUserInteractionEnabled:check];
    [attachmentButton setEnabled:check];
    [messageField setEnabled:check];
    [sendButton setEnabled:check];
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

/// CELL HELPER METHODS ///

-(void)setDateLabel:(UILabel *)label :(NSDate *)date {
    
    // Get the current date and time date.
    NSDateComponents *component = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    
    // Create the time and date strings.
    NSString *currentDate = [NSString stringWithFormat:@"%02ld/%02ld/%ld", (long)[component month], (long)[component day], (long)[component year]];
    NSString *currentTime;
    
    // Create the time string in 12 hour format.
    
    if (([component hour] <= 23) && ([component hour] >= 12)) {
        
        // Convert the hour to single digit format.
        
        if ([component hour] != 12) {
            currentTime = [NSString stringWithFormat:@"%ld:%02ld", (long)([component hour] - 12), (long)[component minute]];
        }
        
        else {
            currentTime = [NSString stringWithFormat:@"%ld:%02ld", (long)[component hour], (long)[component minute]];
        }
        
        // Display the time - PM format.
        currentTime = [NSString stringWithFormat:@"%@ PM", currentTime];
    }
    
    else {
        
        // Display the time - AM format.
        currentTime = [NSString stringWithFormat:@"%ld:%02ld", (long)[component hour], (long)[component minute]];
        currentTime = [NSString stringWithFormat:@"%@ AM", currentTime];
    }
    
    // Set the full date label - 00/00/0000 at 00:00.
    [label setText:[NSString stringWithFormat:@"%@ at %@", currentDate, currentTime]];
}

-(void)createMapScreenshot:(PFObject *)data :(CGRect)frame :(mapScreenshotCompletion)dataBlock {
    
    // Setup the map cache.
    static NSCache *mapCache = nil;
    static dispatch_once_t onceToken;
    
    // Setup the cache object.
    
    dispatch_once(&onceToken, ^{
        mapCache = [NSCache new];
    });
    
    // Access the map cache with the unique ID string.
    UIImage *cachedMap = [mapCache objectForKey:[NSString stringWithFormat:@"MAP-%@", [data objectId]]];
    
    // Check if the map data has been
    // previously stored in the cache.
    
    if (cachedMap) {
        dataBlock(cachedMap);
    }
    
    else {
        
        // Set the map view coordinates.
        MKCoordinateRegion region = { {0.0, 0.0}, {0.0, 0.0} };
        region.center.latitude = [(PFGeoPoint *)[data valueForKey:@"locationData"] latitude];
        region.center.longitude = [(PFGeoPoint *)[data valueForKey:@"locationData"] longitude];
        region.span.longitudeDelta = 0.01f;
        region.span.latitudeDelta = 0.01f;
        
        // Set the map snapshot properties.
        MKMapSnapshotOptions *snapOptions = [[MKMapSnapshotOptions alloc] init];
        snapOptions.region = region;
        snapOptions.size = frame.size;
        snapOptions.scale = [[UIScreen mainScreen] scale];
        
        // Initialise the map snapshot camera.
        MKMapSnapshotter *mapCamera = [[MKMapSnapshotter alloc] initWithOptions:snapOptions];
        
        // Take a picture of the map.
        [mapCamera startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
            
            // Check if the map image was created.
            
            if ((error == nil) && (snapshot.image != nil)) {
                
                // Create the pin image view.
                MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:nil];
                
                // Get the map image data.
                UIImage *image = snapshot.image;
                
                // Create a map + location pin image.
                UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale); {
                    
                    // Set the map image point.
                    [image drawAtPoint:CGPointMake(0.0f, 0.0f)];
                    
                    // Create the point for the image size.
                    CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
                    
                    // Create the pin co-ordinate point.
                    CGPoint point = [snapshot pointForCoordinate:region.center];
                    
                    // Check if the image size and pin point are valid.
                    
                    if (CGRectContainsPoint(rect, point)) {
                        
                        // Draw the pin in the middle of the map.
                        point.x = (point.x + pin.centerOffset.x - (pin.bounds.size.width / 2.0f));
                        point.y = (point.y + pin.centerOffset.y - (pin.bounds.size.height / 2.0f));
                        [pin.image drawAtPoint:point];
                    }
                }
                
                // Get the new map + pin image.
                UIImage *mapPlusPin = UIGraphicsGetImageFromCurrentImageContext();
                
                // Stop the Core Graphics framework.
                UIGraphicsEndImageContext();
                
                // Save the cell map data in the cache.
                [mapCache setObject:mapPlusPin forKey:[NSString stringWithFormat:@"MAP-%@", [data objectId]]];
                
                dataBlock(mapPlusPin);
            }
            
            else {
                dataBlock(nil);
            }
        }];
    }
}

-(void)turnImageViewToCircle:(UIImageView *)picture :(float)size {
    
    // Change the user picture into a circle.
    CGPoint saveCenter = picture.center;
    CGRect newFrame = CGRectMake(picture.frame.origin.x, picture.frame.origin.y, size, size);
    picture.frame = newFrame;
    picture.layer.cornerRadius = (size / 2.0);
    picture.center = saveCenter;
}

/// UITABLEVIEW METHODS ///

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get the current cell data object.
    PFObject *data = [chatMessages objectAtIndex:indexPath.row];
    
    // Update the message status is required.
    [self updateMessageStatus:data];
    
    // Get the current message data tyoe.
    NSString *messageType = [data valueForKey:@"typeData"];
    
    // Check the message type and create the
    // appropriate table view cell object.
    
    if ([messageType isEqualToString:@"Text"]) {
        return [self createTextCell:data];
    }
    
    else if ([messageType isEqualToString:@"Photo"] || [messageType isEqualToString:@"Map"] || [messageType isEqualToString:@"Video"]) {
        return [self createPhotoCell:data :indexPath.row];
    }
    
    else {
        return [self createAudioCell:data :indexPath.row];
    }
}

-(UITableViewCell *)createTextCell:(PFObject *)data {
    
    // Get the message author object.
    PFUser *author = [data valueForKey:@"fromUser"];
    
    // Create the cellID/UI file name string.
    NSString *cellID = nil;
    
    // Create the main colour object.
    UIColor *mainColour;
    
    if ([[author objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        cellID = @"ChatTextCell";
        mainColour = [UIColor colorWithRed:(33/255.0) green:(135/255.0) blue:(75/255.0) alpha:1.0];
    } else {
        cellID = @"ChatTextCellOtherUser";
        mainColour = [UIColor colorWithRed:(204/255.0) green:(204/255.0) blue:(204/255.0) alpha:1.0];
    }
    
    // Delegate call back for cell at index path.
    ChatTextCell *cell = (ChatTextCell *)[chatList dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Change the profile picture into a circle.
    [self turnImageViewToCircle:cell.profilePicture :48.0];
    
    // Get the user's profile data.
    [self getProfilePictureCachedData:author.objectId :^(UIImage *picture, NSString *username) {
        
        if (picture == nil) {
            [cell.profilePicture setImage:[UIImage imageNamed:@"default_profile_pic.png"]];
        } else {
            [cell.profilePicture setImage:picture];
        }
    }];
    
    // Set the message label text.
    [cell.messageLabel setText:[data valueForKey:@"textData"]];
    
    // Set the date label text.
    [self setDateLabel:cell.dateLabel :[data createdAt]];
    
    // Set the triangle image to match the colour of the
    // main box view (green = current user | gray = other user).
    cell.triangleView.image = [cell.triangleView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.triangleView setTintColor:mainColour];
    
    // Curve the edges of the box view.
    [[cell.messageLabelContainer layer] setCornerRadius:4.0];
        
    // Set the content restraints.
    [cell.triangleView setClipsToBounds:YES];
    [cell.dateLabel setClipsToBounds:YES];
    [cell.profilePicture setClipsToBounds:YES];
    [cell.messageLabel setClipsToBounds:YES];
    [cell.messageLabelContainer setClipsToBounds:YES];
    [cell.contentView setClipsToBounds:NO];
    
    return cell;
}

-(UITableViewCell *)createPhotoCell:(PFObject *)data :(NSInteger)index {
    
    // Get the message author object.
    PFUser *author = [data valueForKey:@"fromUser"];
    
    // Create the cellID/UI file name string.
    NSString *cellID = nil;
    
    // Create the main colour object.
    UIColor *mainColour;
    
    if ([[author objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        cellID = @"ChatPhotoCell";
        mainColour = [UIColor colorWithRed:(33/255.0) green:(135/255.0) blue:(75/255.0) alpha:1.0];
    } else {
        cellID = @"ChatPhotoCellOtherUser";
        mainColour = [UIColor colorWithRed:(204/255.0) green:(204/255.0) blue:(204/255.0) alpha:1.0];
    }
    
    // Delegate call back for cell at index path.
    ChatPhotoCell *cell = (ChatPhotoCell *)[chatList dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.tag = index;
    
    // Set the input object data.
    [cell setPassedInData:data];
    [cell setPassedInView:self];
    
    // Start the loading indicator.
    [cell.active startAnimating];
    
    // Reset the main image view.
    [cell.messagePicture setImage:nil];
    
    // Change the profile picture into a circle.
    [self turnImageViewToCircle:cell.profilePicture :48.0];
    
    // Get the user's profile data.
    [self getProfilePictureCachedData:author.objectId :^(UIImage *picture, NSString *username) {
        
        if (picture == nil) {
            [cell.profilePicture setImage:[UIImage imageNamed:@"default_profile_pic.png"]];
        } else {
            [cell.profilePicture setImage:picture];
        }
        
        [cell setPassedInUsername:username];
    }];
    
    // Get the current message data tyoe.
    NSString *messageType = [data valueForKey:@"typeData"];
    
    // Check the message type and load the
    // appropriate table view cell data.
    
    if ([messageType isEqualToString:@"Map"]) {
        
        // Create the map + pin preview image.
        [self createMapScreenshot:data :cell.messagePicture.frame :^(UIImage *picture) {
            
            // Ensure we use the correct cached image.
            
            if (cell.tag == index) {
                [cell.messagePicture setImage:picture];
                [cell.messagePicture setNeedsLayout];
                [cell.active stopAnimating];
            };
        }];
    }
    
    else {
        
        // Get the main message picture.
        [self getMainPictureCachedData:data :^(UIImage *picture, NSString *username) {
            
            // Ensure we use the correct cached image.
            
            if (cell.tag == index) {
                [cell.messagePicture setImage:picture];
                [cell.messagePicture setNeedsLayout];
                [cell.active stopAnimating];
            };
        }];
    }
    
    // Show or hide the play button depending on
    // the data type (if it is a video or not).
    [cell.playVideoButton setAlpha:([messageType isEqualToString:@"Video"] ? 1.0 : 0.0)];
    
    // Set the date label text.
    [self setDateLabel:cell.dateLabel :[data createdAt]];
    
    // Set the triangle image to match the colour of the
    // main box view (green = current user | gray = other user).
    cell.triangleView.image = [cell.triangleView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.triangleView setTintColor:mainColour];
    
    // Curve the edges of the box/picture views.
    [[cell.boxView layer] setCornerRadius:4.0];
    [[cell.messagePicture layer] setCornerRadius:4.0];
        
    // Set the content restraints.
    [cell.boxView setClipsToBounds:YES];
    [cell.triangleView setClipsToBounds:YES];
    [cell.dateLabel setClipsToBounds:YES];
    [cell.profilePicture setClipsToBounds:YES];
    [cell.messagePicture setClipsToBounds:YES];
    [cell.playVideoButton setClipsToBounds:YES];
    [cell.active setClipsToBounds:YES];
    [cell.selectionButton setClipsToBounds:YES];
    [cell.contentView setClipsToBounds:NO];
    
    return cell;
}

-(UITableViewCell *)createAudioCell:(PFObject *)data :(NSInteger)index {
    
    // Get the message author object.
    PFUser *author = [data valueForKey:@"fromUser"];
    
    // Create the cellID/UI file name string.
    NSString *cellID = nil;
    
    // Create the main colour object.
    UIColor *mainColour;
    
    if ([[author objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        cellID = @"ChatAudioCell";
        mainColour = [UIColor colorWithRed:(33/255.0) green:(135/255.0) blue:(75/255.0) alpha:1.0];
    } else {
        cellID = @"ChatAudioCellOtherUser";
        mainColour = [UIColor colorWithRed:(204/255.0) green:(204/255.0) blue:(204/255.0) alpha:1.0];
    }
    
    // Delegate call back for cell at index path.
    ChatAudioCell *cell = (ChatAudioCell *)[chatList dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Set the input object data.
    [cell setPassedInData:data];
    [cell setPassedInView:self];
    
    // Get the audio clip duration value.
    int audioDuration = [[data valueForKey:@"audioDurationData"] intValue];
    
    // Set the audio clip duration label.
    
    if (audioDuration < 10) {
        [cell.durationLabel setText:[NSString stringWithFormat:@"00:0%d", audioDuration]];
    } else {
        [cell.durationLabel setText:[NSString stringWithFormat:@"00:%d", audioDuration]];
    }
    
    // Change the profile picture into a circle.
    [self turnImageViewToCircle:cell.profilePicture :48.0];
    
    // Get the user's profile data.
    [self getProfilePictureCachedData:author.objectId :^(UIImage *picture, NSString *username) {
        
        if (picture == nil) {
            [cell.profilePicture setImage:[UIImage imageNamed:@"default_profile_pic.png"]];
        } else {
            [cell.profilePicture setImage:picture];
        }
    }];
    
    // Set the date label text.
    [self setDateLabel:cell.dateLabel :[data createdAt]];
    
    // Set the triangle image to match the colour of the
    // main box view (green = current user | gray = other user).
    cell.triangleView.image = [cell.triangleView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.triangleView setTintColor:mainColour];
    
    // Curve the edges of the box view.
    [[cell.boxView layer] setCornerRadius:4.0];
    
    // Set the content restraints.
    [cell.boxView setClipsToBounds:YES];
    [cell.triangleView setClipsToBounds:YES];
    [cell.dateLabel setClipsToBounds:YES];
    [cell.profilePicture setClipsToBounds:YES];
    [cell.titleLabel setClipsToBounds:YES];
    [cell.durationLabel setClipsToBounds:YES];
    [cell.playButton setClipsToBounds:YES];
    [cell.selectionButton setClipsToBounds:YES];
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
    return [self getHeightCachedData:chatMessages[indexPath.row]];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [chatMessages count];
}

/// LOCATION MANAGER METHODS ///

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    // Check if the user has given permission to view
    // their location information and then load the data.
    
    if ([CLLocationManager locationServicesEnabled]) {
        
        // Check to see if location access has been granted.
        
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            
            // The user has granted permission.
            [manager startUpdatingLocation];
        }
        
        else if (status == kCLAuthorizationStatusRestricted) {
            
            // The user has restricted permission.
            [manager stopUpdatingLocation];
        }
        
        else if (status == kCLAuthorizationStatusDenied) {
            
            // The user has denied permission.
            [manager stopUpdatingLocation];
        }
    }
    
    else {
        
        // Location data is not available.
        [manager stopUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    // Stop getting the location information.
    [manager stopUpdatingLocation];
}

/// IMAGEPICKER METHODS ///

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // Get the passed in media type.
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    // Check if the selected media is a photo or video.
    BOOL videoCheck = UTTypeConformsTo((__bridge CFStringRef)mediaType, kUTTypeMovie) != 0;
    
    // Perform the correct action depending
    // on the passed in media file type.
    
    if (videoCheck == YES) {
        
        // Save the video file to the local user library.
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum((NSString *)[[info objectForKey:UIImagePickerControllerMediaURL] path])) {
            UISaveVideoAtPathToSavedPhotosAlbum((NSString *)[[info objectForKey:UIImagePickerControllerMediaURL] path], nil, nil, nil);
        }
        
        // No present the media player.
        [picker dismissViewControllerAnimated:YES completion:^{
            
            // Get the video data and video thumbnail.
            videoData = [NSData dataWithContentsOfURL:(NSURL *)info[UIImagePickerControllerMediaURL]];
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:(NSURL *)info[UIImagePickerControllerMediaURL] options:nil];
            id imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
            UIImage *videoThumbnail = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil]];
            
            // Hide the on screen keyboard.
            [self dismissKeyboard];
            
            // Send the video message.
            [self sendMessage:@"Video" :videoThumbnail];
        }];
        
    } else {
        
        // Get the image which has been taken.
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        
        // Save the image to the users library.
        UIImageWriteToSavedPhotosAlbum(chosenImage, nil, nil, nil);
        
        // Send the image/video message.
        [picker dismissViewControllerAnimated:YES completion:^{
            
            // Hide the on screen keyboard.
            [self dismissKeyboard];
            
            // Send the photo message.
            [self sendMessage:@"Photo" :chosenImage];
        }];
    }
}

/// AUDIOPLAYER METHODS ///

-(BOOL)checkHeadphones {
    
    // Get the AVSession audio data.
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance] currentRoute];
    
    // Loop through the data to figure out
    // if the headphones are connected.
    
    for (AVAudioSessionPortDescription *desc in [route outputs]) {
        
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones]) {
            return YES;
        }
    }
    
    return NO;
}

-(void)audioRouteChangeListenerCallback:(NSNotification *)notification {
    
    // If the headphones are not connected
    // then play the audio through the speakers.
    
    if ([self checkHeadphones] == NO) {
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
}

/// IQAUDIORECORDERVIEWCONTROLLER METHODS ///

-(void)audioRecorderController:(IQAudioRecorderViewController *)controller didFinishWithAudioAtPath:(NSString *)filePath {
    
    // Get the audio data file.
    AVURLAsset *audioAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    
    // Get the duration of the audio file.
    CMTime audioDuration = audioAsset.duration;
    int audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    
    // Send the voice message.
    [self sendMessage:@"Audio" :@[[NSNumber numberWithInt:audioDurationSeconds], [PFFile fileWithName:@"sound.m4a" data:[NSData dataWithContentsOfFile:filePath]]]];
    
    // Close the custom audio recorder view.
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)audioRecorderControllerDidCancel:(IQAudioRecorderViewController *)controller {
    
    // Close the custom audio recorder view.
    [controller dismissViewControllerAnimated:YES completion:nil];
}

/// UITEXTFIELD METHODS ///

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // Trim the chat string text.
    NSString *chatString = [messageField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Check if the chat data is valid or not
    // before performing the upload request.
    
    if (([chatString length] > 0) && (messageField.text != nil)) {
        
        // Hide the on screen keyboard.
        [self dismissKeyboard];
        
        // Send the text message.
        [self sendMessage:@"Text" :messageField.text];
    }
    
    return YES;
}

/// OTHER METHODS ///

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
