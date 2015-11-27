//
//  reportBug.m
//  Calendario
//
//  Created by Harith Bakri on 21/11/2015.
//  Copyright © 2015 Calendario. All rights reserved.
//

#import "reportBug.h"
#import "Calendario-Swift.h"

@interface reportBug ()

@end

@implementation reportBug

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)Send:(id)sender {
    
    NSString *titleString = _titleField.text;
    NSString *descString = _descField.text;
    
    PFObject *newReport = [PFObject objectWithClassName:@"reportBugs"];
    newReport[@"bugTitle"]= titleString;
    newReport[@"BugDesc"] = descString;
    
    [newReport saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The object has been saved.
        } else {
            // There was a problem, check error.description
        }
    }];
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

@end
