//
//  ChatPhotoCell.h
//  Calendario
//
//  Created by Daniel Sadjadian on 22/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface ChatPhotoCell : UITableViewCell <AVPlayerViewControllerDelegate> {
    
}

// Buttons.
-(IBAction)mediaSelected:(id)sender;

// Background bubble box view.
@property (strong, nonatomic) IBOutlet UIView *boxView;
@property (strong, nonatomic) IBOutlet UIImageView *triangleView;

// Message creation date label.
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

// User profile picture image.
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;

// Main photo view.
@property (strong, nonatomic) IBOutlet UIImageView *messagePicture;

// Play video button.
@property (strong, nonatomic) IBOutlet UIImageView *playVideoButton;

// Data loading indicator.
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *active;

// Main cell selection button.
@property (strong, nonatomic) IBOutlet UIButton *selectionButton;

// Properties - strings, contacts, etc..
@property (nonatomic, retain) PFObject *passedInData;
@property (nonatomic, retain) NSString *passedInUsername;
@property (nonatomic, retain) UIViewController *passedInView;

@end
