//
//  ChatPhotoCell.h
//  Calendario
//
//  Created by Daniel Sadjadian on 22/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatPhotoCell : UITableViewCell {
    
}

// Background bubble box view.
@property (strong, nonatomic) IBOutlet UIView *boxView;
@property (strong, nonatomic) IBOutlet UIImageView *triangleView;

// Message creation date label.
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

// User profile picture image.
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;

// Main photo view.
@property (strong, nonatomic) IBOutlet UIImageView *messagePicture;

@end
