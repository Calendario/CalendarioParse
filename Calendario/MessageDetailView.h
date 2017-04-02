//
//  MessageDetailView.h
//  Calendario
//
//  Created by Daniel Sadjadian on 22/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <Photos/Photos.h>
#import <Parse/Parse.h>
#import "ChatTextCell.h"
#import "ChatPhotoCell.h"
#import "ChatAudioCell.h"
#import "MessageLocationViewer.h"

typedef void(^pictureCompletion)(UIImage *picture, NSString *username);
typedef void(^mapScreenshotCompletion)(UIImage *picture);
typedef void(^locationCheckCompletion)(BOOL dataCheck);

@interface MessageDetailView : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, AVPlayerViewControllerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITextFieldDelegate> {
    
    // Message container views.
    IBOutlet UITextField *messageField;
    IBOutlet UIView *commentContainer;
    IBOutlet UIButton *sendButton;
    
    // Message chat list.
    IBOutlet UITableView *chatList;
    
    // Message chat data.
    NSMutableArray *chatMessages;
    
    // Current location data.
    CLLocationManager *locationManager;
        
    // Audio recording custom view.
    IBOutlet UIButton *sendAudioButton;
    
    // Data reload timer.
    NSTimer *reloadTimer;
    
    // No message data label.
    IBOutlet UILabel *noDataLabel;
}

// Buttons.
-(IBAction)done:(id)sender;
-(IBAction)send:(id)sender;
-(IBAction)addAttachment:(id)sender;

// Data methods.
-(void)loadAllMessages;
-(void)sendMessage:(NSString *)messageType :(id)data;
-(void)setMessageQueryData:(NSString *)messageType :(id)data;
-(void)getProfilePictureCachedData:(NSString *)userID :(pictureCompletion)dataBlock;
-(void)getMainPictureCachedData:(PFObject *)data :(pictureCompletion)dataBlock;
-(float)getHeightCachedData:(PFObject *)data;
-(void)updateMessageStatus:(PFObject *)data;
-(void)checkCurrentLocation:(locationCheckCompletion)dataBlock;
-(void)locationReceived:(NSNotification *)object;

// Keyboard methods.
-(void)keyboardWillShow:(NSNotification *)object;
-(void)dismissKeyboard;

// UI methods.
-(void)openAudioRecorder;
-(void)updateNoDataLabel;
-(void)scrollToBottomOfList:(BOOL)animated;

// Info methods.
-(void)displayAlert:(NSString *)title :(NSString *)message;

// Cell helper methods.
-(void)setDateLabel:(UILabel *)label :(NSDate *)date;
-(void)createMapScreenshot:(PFObject *)data :(CGRect)frame :(mapScreenshotCompletion)dataBlock;
-(void)turnImageViewToCircle:(UIImageView *)picture :(float)size;

// Properties - strings, contacts, etc..
@property (nonatomic, retain) PFUser *passedInUser;
@property (nonatomic, retain) PFObject *passedInThread;

@end
