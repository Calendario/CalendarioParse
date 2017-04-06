//
//  ChatAudioCell.m
//  Calendario
//
//  Created by Daniel Sadjadian on 22/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import "ChatAudioCell.h"

@implementation ChatAudioCell
@synthesize passedInData;
@synthesize passedInView;

/// BUTTONS ///

-(IBAction)playAudio:(id)sender {
    
    NSLog(@"TESTING");
    
    // Get the audio file object.
    PFFile *audioFile = [passedInData valueForKey:@"audioData"];
    
    // Play the message audio file.
    AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:[audioFile url]]];
    AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
    [controller setPlayer:player];
    [controller setDelegate:self];
    
    // Open the player view and play the audio clip.
    [passedInView presentViewController:controller animated:YES completion:^{
        [player play];
    }];
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
