//
//  ChatTextCell.h
//  Calendario
//
//  Created by Daniel Sadjadian on 22/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatTextCell : UITableViewCell {
    
}

// Background bubble triangle view, the background box
// view is not needed for this particular cell type.
@property (strong, nonatomic) IBOutlet UIImageView *triangleView;

// Message creation date label.
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

// User profile picture image.
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;

// Main message label.
@property (strong, nonatomic) IBOutlet UITextView *messageLabel;

@end
