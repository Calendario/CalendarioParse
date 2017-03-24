//
//  ChatAudioCell.m
//  Calendario
//
//  Created by Daniel Sadjadian on 22/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import "ChatAudioCell.h"
#import <Parse/Parse.h>

@implementation ChatAudioCell
@synthesize passedInData;

/// BUTTONS ///

-(IBAction)playAudio:(id)sender {
    
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
