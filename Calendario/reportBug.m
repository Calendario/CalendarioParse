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

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // Add a 'Done' button/toolbar to the keyboard.
    UIToolbar *done_toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 50)];
    done_toolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *done_button = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissTextView)];
    
    done_toolbar.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], done_button, nil];
    
    [done_toolbar sizeToFit];
    _descField.inputAccessoryView = done_toolbar;
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)dismissTextView {
    [_descField resignFirstResponder];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    
    // Show the placeholder text view
    // if no text has been entered.
    
    if ([textView hasText]) {
        _descFieldPlaceholder.alpha = 0.0;
    }
    
    else {
        _descFieldPlaceholder.alpha = 1.0;
    }
}

-(void)textViewDidChange:(UITextView *)textView {
    
    // Show or hide the place holder text
    // view depending on whether or not a bug
    // description has been entered by the user.
    
    if ([textView hasText]) {
        _descFieldPlaceholder.alpha = 0.0;
    }
    
    else {
        _descFieldPlaceholder.alpha = 1.0;
    }
}

-(IBAction)Send:(id)sender {
    
    // Check the report details before submitting.
    NSString *titleCheck = [_titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *descCheck = [_descField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (((titleCheck != nil) && (titleCheck.length > 0)) && ((descCheck != nil) && (descCheck.length > 0))) {
        
        PFObject *newReport = [PFObject objectWithClassName:@"reportBugs"];
        newReport[@"bugTitle"]= _titleField.text;
        newReport[@"BugDesc"] = _descField.text;
        
        [newReport saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                
                if (succeeded) {
                    
                    // The report has been saved.
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                
                else {
                    
                    // Create the error message.
                    NSString *errorMessage = [NSString stringWithFormat:@"Calendario is unable to submit your bug report (Error: %@)", error.localizedDescription];
                    
                    // An error has occured sending the bug report.
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
                    
                    // Create the alert actions.
                    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    // Add the action and present the alert.
                    [alert addAction:dismiss];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }];
        }];
    }
    
    else {
        
        // An error has occured sending the bug report.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter a report title and description before submitting the report." preferredStyle:UIAlertControllerStyleAlert];
        
        // Create the alert actions.
        UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        
        // Add the action and present the alert.
        [alert addAction:dismiss];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

-(IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
