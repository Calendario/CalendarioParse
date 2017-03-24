//
//  ChatAudioCell.h
//  Calendario
//
//  Created by Daniel Sadjadian on 22/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatAudioCell : UITableViewCell {
    
}

// Buttons.
-(IBAction)playAudio:(id)sender;

// Background bubble box view.
@property (strong, nonatomic) IBOutlet UIView *boxView;
@property (strong, nonatomic) IBOutlet UIImageView *triangleView;

// Message creation date label.
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

// User profile picture image.
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;

// Message audio player views.
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UIButton *playButton;

// Passed in data object.
@property (nonatomic, retain) NSArray *passedInData;

@end
