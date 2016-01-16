//
//  reportBug.h
//  Calendario
//
//  Created by Harith Bakri on 21/11/2015.
//  Copyright © 2015 Calendario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface reportBug : UIViewController <UITextFieldDelegate>

-(IBAction)Send:(id)sender;
-(IBAction)backgroundTap:(id)sender;
-(IBAction)close:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextView *descField;
@property (weak, nonatomic) IBOutlet UITextView *descFieldPlaceholder;

@end
