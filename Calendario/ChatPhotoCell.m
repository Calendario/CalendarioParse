//
//  ChatPhotoCell.m
//  Calendario
//
//  Created by Daniel Sadjadian on 22/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import "ChatPhotoCell.h"
#import "MessageLocationViewer.h"
#import "Calendario-Swift.h"

@implementation ChatPhotoCell
@synthesize passedInData;
@synthesize passedInUsername;
@synthesize passedInView;

/// BUTTONS ///

-(IBAction)mediaSelected:(id)sender {
    
    // Get the current message data tyoe.
    NSString *messageType = [passedInData valueForKey:@"typeData"];
    
    // Connect the button to the right method.
    
    if ([messageType isEqualToString:@"Photo"]) {
        
        // View the image in the full image viewer.
        UIStoryboard *storyFile = [UIStoryboard storyboardWithName:@"FullimageViewController" bundle:nil];
        FullimageViewController *screen = [storyFile instantiateViewControllerWithIdentifier:@"photoViewer"];
        [screen setPassedImage:self.messagePicture.image];
        [screen setPassedUserName:(passedInUsername == nil ? @"" : passedInUsername)];
        [screen setPassedObject:nil];
        [screen setPassedUserProfileImage:self.profilePicture.image];
        [passedInView presentViewController:screen animated:YES completion:nil];
    }
    
    else if ([messageType isEqualToString:@"Video"]) {
        
        // Get the video file object.
        PFFile *videoFile = [passedInData valueForKey:@"videoData"];
        
        // Play the message video file.
        AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:[videoFile url]]];
        AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
        [controller setPlayer:player];
        [controller setDelegate:self];
        
        // Open the player view and play the video clip.
        [passedInView presentViewController:controller animated:YES completion:^{
            [player play];
        }];
    }
    
    else if ([messageType isEqualToString:@"Map"]) {
        
        // Open the location detail view.
        UIStoryboard *storyFile = [UIStoryboard storyboardWithName:@"MessageLocationViewer" bundle:nil];
        MessageLocationViewer *screen = [storyFile instantiateViewControllerWithIdentifier:@"MessageLocationViewer"];
        [screen setPassedInData:passedInData];
        [passedInView presentViewController:screen animated:YES completion:nil];
    }
}

/// OTHER METHODS ///

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
