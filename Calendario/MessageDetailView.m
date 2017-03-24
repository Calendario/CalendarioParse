//
//  MessageDetailView.m
//  Calendario
//
//  Created by Daniel Sadjadian on 22/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import "MessageDetailView.h"

@interface MessageDetailView () {
    PFObject *newMessage;
}

@end

@implementation MessageDetailView
@synthesize passedInUser;
@synthesize passedInThread;

/// BUTTONS ///

-(IBAction)done:(id)sender {
    
    [self dismissKeyboard];
    
    if (audioPlayer.playing == YES) {
        [audioPlayer stop];
    }
    
    if (audioRecorder.recording == YES) {
        [audioRecorder stop];
    }
    
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
        [self dismissKeyboard];
        [self sendMessage:@"Text" :messageField.text];
    }
}

-(IBAction)addAttachment:(id)sender {
    
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
        
        [self checkCurrentLocation:^(BOOL dataCheck) {
            
            if (dataCheck == YES) {
                [self sendMessage:@"Map" :[PFGeoPoint geoPointWithLatitude:locationManager.location.coordinate.latitude longitude:locationManager.location.coordinate.longitude]];
            }
        }];
    }];
    
    UIAlertAction *audio = [UIAlertAction actionWithTitle:@"Voice message" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
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

-(IBAction)startRecording:(id)sender {
    
    // Check the microphone authorisation status.
    AVAuthorizationStatus statusMicrophone = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    // Check the status responce and act acoordingly.
    
    if (statusMicrophone == AVAuthorizationStatusAuthorized) {
        
        if (audioRecorder.recording) {
            [audioRecorder stop];
            [recordAudioButton setTitle:@"Record" forState:UIControlStateNormal];
        } else {
            [recordAudioButton setTitle:@"Stop" forState:UIControlStateNormal];
            [audioRecorder record];
        }
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
                    
                    if (audioRecorder.recording) {
                        [audioRecorder stop];
                        [recordAudioButton setTitle:@"Record" forState:UIControlStateNormal];
                    } else {
                        [recordAudioButton setTitle:@"Stop" forState:UIControlStateNormal];
                        [audioRecorder record];
                    }
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
}

-(IBAction)playCurrentRecording:(id)sender {
    
    if (!audioRecorder.recording) {
        
        if (audioPlayer.playing == YES) {
            [audioPlayer stop];
            [playAudioButton setTitle:@"Play" forState:UIControlStateNormal];
        } else {
            
            NSError *error = nil;
            
            audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioRecorder.url error:&error];
            [audioPlayer setDelegate:self];
            
            if (error) {
                NSLog(@"Error: %@", [error localizedDescription]);
            } else {
                [audioPlayer play];
                [playAudioButton setTitle:@"Pause" forState:UIControlStateNormal];
            }
        }
    }
}

-(IBAction)sendVoiceMessage:(id)sender {
    
    // Send the voice message.
    [self sendVoiceMessage:[PFFile fileWithName:@"sound.caf" data:[NSData dataWithContentsOfURL:audioRecorder.url]]];
}

-(IBAction)closeRecordView:(id)sender {
    
    // Stop the audio player if its playing.
    
    if (audioPlayer.playing == YES) {
        [audioPlayer stop];
    }
    
    // Stop the audio recorder if its recording.
    
    if (audioRecorder.recording == YES) {
        [audioRecorder stop];
    }
    
    // Close the record view.
    [UIView animateWithDuration:0.3 delay:0.0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
        [audioBackgroundView setAlpha:(audioBackgroundView.alpha > 0 ? 0.0 : 1.0)];
    } completion:^(BOOL finished) {
        [recordAudioButton setEnabled:YES];
        [recordAudioButton setTitle:@"Record" forState:UIControlStateNormal];
        [playAudioButton setEnabled:NO];
        [playAudioButton setUserInteractionEnabled:NO];
        [playAudioButton setTitle:@"Play" forState:UIControlStateNormal];
    }];
}

/// VIEW DID LOAD ///

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Setup the location manager class.
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager requestWhenInUseAuthorization];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [locationManager startUpdatingLocation];
    
    // Curve the egdes of the record/send button views.
    [[audioView layer] setCornerRadius:4.0];
    [[sendButton layer] setCornerRadius:4.0];
    
    // Hide the audio view by default.
    [audioBackgroundView setAlpha:0.0];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.caf"];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey, [NSNumber numberWithInt:16], AVEncoderBitRateKey, [NSNumber numberWithInt:2], AVNumberOfChannelsKey, [NSNumber numberWithFloat:44100.0], AVSampleRateKey, nil];
    
    NSError *error = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:soundFileURL settings:recordSettings error:&error];
    
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [audioRecorder prepareToRecord];
    }
    
    // Load all the thread messages.
    [self loadAllMessages];
    
    // Keep checking for new thread messages (every 1.5 seconds).
    reloadTimer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(loadAllMessages) userInfo:nil repeats:YES];
}

/// DATA METHODS ///

-(void)loadAllMessages {
    
    if (passedInThread != nil) {
        
        // Setup the messages media data query.
        PFQuery *messageQuery = [PFQuery queryWithClassName:@"privateMessagesMedia"];
        [messageQuery whereKey:@"threadID" equalTo:[passedInThread objectId]];
        
        // Run the message media query.
        [messageQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            
            if (error == nil) {
                
                if ([objects count] > 0) {
                    chatMessages = [objects mutableCopy];
                } else {
                    [chatMessages removeAllObjects];
                }
                
                [chatList reloadData];
            }
        }];
    }
}

-(void)sendMessage:(NSString *)messageType :(id)data {
    
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
                
                if (object == nil) {
                    [self uploadMessageData:messageType :nil :data];
                } else {
                    [self uploadMessageData:messageType :object :data];
                }
                
            } else {
                [self uploadMessageData:messageType :nil :data];
            }
        }];
        
    } else {
        [self uploadMessageData:messageType :passedInThread :data];
    }
}

-(void)uploadMessageData:(NSString *)messageType :(PFObject *)thread :(id)data {
    
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
                
                // Set the query info data.
                [self setMessageQueryData:messageType :data];
                
                // Upload the new message data.
                [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if ((succeeded) && (error == nil)) {
                        [messageField setText:nil];
                        [self loadAllMessages];
                    }
                }];
            }
        }];
        
    } else {
        
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
                    
                    // Set the query info data.
                    [self setMessageQueryData:messageType :data];
                    
                    // Upload the new message data.
                    [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if ((succeeded) && (error == nil)) {
                            [messageField setText:nil];
                            [self loadAllMessages];
                        }
                    }];
                }
            }];
            
        } else {
            
            // Create the new message object.
            newMessage = [PFObject objectWithClassName:@"privateMessagesMedia"];
            newMessage[@"threadID"] = [thread objectId];
            newMessage[@"fromUser"] = [PFUser currentUser];
            newMessage[@"typeData"] = messageType;
            
            // Set the query info data.
            [self setMessageQueryData:messageType :data];
            
            // Upload the new message data.
            [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if ((succeeded) && (error == nil)) {
                    [messageField setText:nil];
                    [self loadAllMessages];
                }
            }];
        }
    }
}

-(void)setMessageQueryData:(NSString *)messageType :(id)data {
    
    if ([messageType isEqualToString:@"Text"]) {
        newMessage[@"textData"] = data;
    }
    
    else if ([messageType isEqualToString:@"Photo"]) {
        newMessage[@"photoData"] = data;
    }
    
    else if ([messageType isEqualToString:@"Map"]) {
        newMessage[@"locationData"] = data;
    }
    
    else if ([messageType isEqualToString:@"Video"]) {
        newMessage[@"photoData"] = (NSArray *)data[0];
        newMessage[@"videoData"] = (NSArray *)data[1];
    }
    
    else {
        newMessage[@"audioData"] = data;
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
    NSString *pictureKey = [NSString stringWithFormat:@"%@-Picture", userID];
    
    // Access the user cache with the unique ID string.
    UIImage *cachedUserPicture = [userCache objectForKey:pictureKey];
    
    // Check if the user data has been
    // previously stored in the cache.
    
    if (cachedUserPicture) {
        dataBlock(cachedUserPicture);
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
                        [userCache setObject:image forKey:pictureKey];
                        
                        dataBlock(image);
                        
                    } else {
                        dataBlock(nil);
                    }
                }];
                
            } else {
                dataBlock(nil);
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
    NSString *pictureKey = [NSString stringWithFormat:@"%@-Picture", [data objectId]];
    
    // Access the picture cache with the unique ID string.
    UIImage *cachedMainPicture = [pictureCache objectForKey:pictureKey];
    
    // Check if the main picture data has
    // been previously stored in the cache.
    
    if (cachedMainPicture) {
        dataBlock(cachedMainPicture);
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
                
                dataBlock(image);
                
            } else {
                dataBlock(nil);
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
    
    // Access the height cache with the unique ID string.
    NSNumber *cachedHeight = [heightCache objectForKey:[data objectId]];
    
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
        
        if ([messageType isEqualToString:@"Text"] || [messageType isEqualToString:@"Audio"]) {
            cellHeight = 103;
        }
        
        else {
            cellHeight = 183;
        }
        
        // Save the cell height data in the cache.
        [heightCache setObject:[NSNumber numberWithFloat:cellHeight] forKey:[data objectId]];
        
        return cellHeight;
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

/// KEYBOARD METHODS ///

-(void)keyboardWillShow:(NSNotification *)object {
    
    float height = [[[object userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
        commentContainer.frame = CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height - height - commentContainer.frame.size.height), [[UIScreen mainScreen] bounds].size.width, commentContainer.frame.size.height);
    } completion:nil];
}

-(void)dismissKeyboard {
    
    [messageField resignFirstResponder];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
        commentContainer.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width, commentContainer.frame.size.height);
    } completion:nil];
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

-(void)createMapScreenshot:(MKCoordinateRegion)region :(NSString *)dataID :(CGRect)frame :(mapScreenshotCompletion)dataBlock {
    
    // Setup the map cache.
    static NSCache *mapCache = nil;
    static dispatch_once_t onceToken;
    
    // Setup the cache object.
    
    dispatch_once(&onceToken, ^{
        mapCache = [NSCache new];
    });
    
    // Access the map cache with the unique ID string.
    UIImage *cachedMap = [mapCache objectForKey:dataID];
    
    // Check if the map data has been
    // previously stored in the cache.
    
    if (cachedMap) {
        dataBlock(cachedMap);
    }
    
    else {
        
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
                [mapCache setObject:mapPlusPin forKey:dataID];
                
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
    
    // Get the current message data tyoe.
    NSString *messageType = [data valueForKey:@"typeData"];
    
    // Check the message type and create the
    // appropriate table view cell object.
    
    if ([messageType isEqualToString:@"Text"]) {
        return [self createTextCell:data];
    }
    
    else if ([messageType isEqualToString:@"Photo"]) {
        return [self createPhotoCell:data];
    }
    
    else if ([messageType isEqualToString:@"Map"]) {
        return [self createMapCell:data];
    }
    
    else if ([messageType isEqualToString:@"Video"]) {
        return [self createVideoCell:data];
    }
    
    else {
        return [self createAudioCell:data];
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
    [self getProfilePictureCachedData:author.objectId :^(UIImage *picture) {
        
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
    [[cell.messageLabel layer] setCornerRadius:4.0];
    
    // Set the content restraints.
    [cell.triangleView setClipsToBounds:YES];
    [cell.dateLabel setClipsToBounds:YES];
    [cell.profilePicture setClipsToBounds:YES];
    [cell.messageLabel setClipsToBounds:YES];
    [cell.contentView setClipsToBounds:NO];
    
    return cell;
}

-(UITableViewCell *)createPhotoCell:(PFObject *)data {
    
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
    
    // Change the profile picture into a circle.
    [self turnImageViewToCircle:cell.profilePicture :48.0];
    
    // Get the user's profile data.
    [self getProfilePictureCachedData:author.objectId :^(UIImage *picture) {
        
        if (picture == nil) {
            [cell.profilePicture setImage:[UIImage imageNamed:@"default_profile_pic.png"]];
        } else {
            [cell.profilePicture setImage:picture];
        }
    }];
    
    // Get the main message picture.
    [self getMainPictureCachedData:data :^(UIImage *picture) {
        [cell.messagePicture setImage:picture];
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
    [cell.messagePicture setClipsToBounds:YES];
    [cell.contentView setClipsToBounds:NO];
    
    return cell;
}

-(UITableViewCell *)createMapCell:(PFObject *)data {
    
    // Get the message author object.
    PFUser *author = [data valueForKey:@"fromUser"];
    
    // Create the cellID/UI file name string.
    NSString *cellID = nil;
    
    // Create the main colour object.
    UIColor *mainColour;
    
    if ([[author objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        cellID = @"ChatMapCell";
        mainColour = [UIColor colorWithRed:(33/255.0) green:(135/255.0) blue:(75/255.0) alpha:1.0];
    } else {
        cellID = @"ChatMapCellOtherUser";
        mainColour = [UIColor colorWithRed:(204/255.0) green:(204/255.0) blue:(204/255.0) alpha:1.0];
    }
    
    // Delegate call back for cell at index path.
    ChatMapCell *cell = (ChatMapCell *)[chatList dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Change the profile picture into a circle.
    [self turnImageViewToCircle:cell.profilePicture :48.0];
    
    // Get the user's profile data.
    [self getProfilePictureCachedData:author.objectId :^(UIImage *picture) {
        
        if (picture == nil) {
            [cell.profilePicture setImage:[UIImage imageNamed:@"default_profile_pic.png"]];
        } else {
            [cell.profilePicture setImage:picture];
        }
    }];
    
    // Set the map view coordinates.
    MKCoordinateRegion region = { {0.0, 0.0}, {0.0, 0.0} };
    region.center.latitude = [(PFGeoPoint *)[data valueForKey:@"locationData"] latitude];
    region.center.longitude = [(PFGeoPoint *)[data valueForKey:@"locationData"] longitude];
    region.span.longitudeDelta = 0.01f;
    region.span.latitudeDelta = 0.01f;
    
    // Create the map + pin preview image.
    [self createMapScreenshot:region :[data objectId] :cell.mapPreview.frame :^(UIImage *picture) {
        [cell.mapPreview setImage:picture];
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
    [cell.mapPreview setClipsToBounds:YES];
    [cell.contentView setClipsToBounds:NO];
    
    return cell;
}

-(UITableViewCell *)createVideoCell:(PFObject *)data {
    
    // Get the message author object.
    PFUser *author = [data valueForKey:@"fromUser"];
    
    // Create the cellID/UI file name string.
    NSString *cellID = nil;
    
    // Create the main colour object.
    UIColor *mainColour;
    
    if ([[author objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        cellID = @"ChatVideoCell";
        mainColour = [UIColor colorWithRed:(33/255.0) green:(135/255.0) blue:(75/255.0) alpha:1.0];
    } else {
        cellID = @"ChatVideoCellOtherUser";
        mainColour = [UIColor colorWithRed:(204/255.0) green:(204/255.0) blue:(204/255.0) alpha:1.0];
    }
    
    // Delegate call back for cell at index path.
    ChatVideoCell *cell = (ChatVideoCell *)[chatList dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Set the cell pass in data object.
    cell.passedInData = @[self, data];
    
    // Change the profile picture into a circle.
    [self turnImageViewToCircle:cell.profilePicture :48.0];
    
    // Get the user's profile data.
    [self getProfilePictureCachedData:author.objectId :^(UIImage *picture) {
        
        if (picture == nil) {
            [cell.profilePicture setImage:[UIImage imageNamed:@"default_profile_pic.png"]];
        } else {
            [cell.profilePicture setImage:picture];
        }
    }];
    
    // Get the main message picture.
    [self getMainPictureCachedData:data :^(UIImage *picture) {
        [cell.videoThumbnail setImage:picture];
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
    [cell.videoThumbnail setClipsToBounds:YES];
    [cell.playButton setClipsToBounds:YES];
    [cell.contentView setClipsToBounds:NO];
    
    return cell;
}

-(UITableViewCell *)createAudioCell:(PFObject *)data {
    
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
    
    // Set the cell pass in data object.
    cell.passedInData = @[self, data];
    
    // Change the profile picture into a circle.
    [self turnImageViewToCircle:cell.profilePicture :48.0];
    
    // Get the user's profile data.
    [self getProfilePictureCachedData:author.objectId :^(UIImage *picture) {
        
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
        
    // Store the photo if one has been taken.
    UIImage *chosenImage;
    
    // Get the image which has been taken.
    chosenImage = info[UIImagePickerControllerEditedImage];
    
    // Save the image to the users library.
    UIImageWriteToSavedPhotosAlbum(chosenImage, nil, nil, nil);
    
    // Send the image/video message.
    [picker dismissViewControllerAnimated:YES completion:^{
        [self sendMessage:@"Photo" :chosenImage];
    }];
}

/// AUDIOPLAYER METHODS ///

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    
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
