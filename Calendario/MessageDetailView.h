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
#import <MobileCoreServices/UTCoreTypes.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <Parse/Parse.h>
#import "ChatTextCell.h"
#import "ChatPhotoCell.h"
#import "ChatMapCell.h"
#import "ChatVideoCell.h"
#import "ChatAudioCell.h"

typedef void(^pictureCompletion)(UIImage *picture);
typedef void(^mapScreenshotCompletion)(UIImage *picture);
typedef void(^locationCheckCompletion)(BOOL dataCheck);

@interface MessageDetailView : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate> {
    
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
    
    // Audio message recorder.
    AVAudioPlayer *audioPlayer;
    AVAudioRecorder *audioRecorder;
    
    // Audio recording custom view.
    IBOutlet UIView *audioView;
    IBOutlet UILabel *audioDuration;
    IBOutlet UIButton *recordAudioButton;
    IBOutlet UIButton *playAudioButton;
    IBOutlet UIButton *sendAudioButton;
    IBOutlet UIView *audioBackgroundView;
    
    // Data reload timer.
    NSTimer *reloadTimer;
}

// Buttons.
-(IBAction)done:(id)sender;
-(IBAction)send:(id)sender;
-(IBAction)addAttachment:(id)sender;
-(IBAction)startRecording:(id)sender;
-(IBAction)playCurrentRecording:(id)sender;
-(IBAction)sendVoiceMessage:(id)sender;
-(IBAction)closeRecordView:(id)sender;

// Data methods.
-(void)loadAllMessages;
-(void)sendMessage:(NSString *)messageType :(id)data;
-(void)setMessageQueryData:(NSString *)messageType :(id)data;
-(void)getProfilePictureCachedData:(NSString *)userID :(pictureCompletion)dataBlock;
-(void)getMainPictureCachedData:(PFObject *)data :(pictureCompletion)dataBlock;
-(float)getHeightCachedData:(PFObject *)data;
-(void)checkCurrentLocation:(locationCheckCompletion)dataBlock;

// Keyboard methods.
-(void)keyboardWillShow:(NSNotification *)object;
-(void)dismissKeyboard;

// Info methods.
-(void)displayAlert:(NSString *)title :(NSString *)message;

// Cell helper methods.
-(void)setDateLabel:(UILabel *)label :(NSDate *)date;
-(void)createMapScreenshot:(MKCoordinateRegion)region :(NSString *)dataID :(CGRect)frame :(mapScreenshotCompletion)dataBlock;
-(void)turnImageViewToCircle:(UIImageView *)picture :(float)size;

// Properties - strings, contacts, etc..
@property (nonatomic, retain) PFUser *passedInUser;
@property (nonatomic, retain) PFObject *passedInThread;

@end
