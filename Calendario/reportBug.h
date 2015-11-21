//
//  reportBug.h
//  Calendario
//
//  Created by Harith Bakri on 21/11/2015.
//  Copyright © 2015 Calendario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface reportBug : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *descField;
- (IBAction)Send:(id)sender;

@end
