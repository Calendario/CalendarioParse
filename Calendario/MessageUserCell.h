//
//  MessageUserCell.h
//  Calendario
//
//  Created by Daniel Sadjadian on 22/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageUserCell : UITableViewCell {
    
}

// User profile picture.
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;

// User name label.
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;

@end
