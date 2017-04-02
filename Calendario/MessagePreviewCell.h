//
//  MessagePreviewCell.h
//  Calendario
//
//  Created by Daniel Sadjadian on 21/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagePreviewCell : UITableViewCell {
    
}

// Other user profile picture.
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;

// Messeage title/desc/date labels.
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@end
