//
//  CalHashTagDetector.m
//  Calendario
//
//  Created by Derek Cacciotti on 10/19/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

#import "CalHashTagDetector.h"


@implementation CalHashTagDetector

NSString *Pword;
-(NSMutableAttributedString *) decorateTags:(NSString *)stringWithTags
{
  
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    
    
    
    NSArray *matches = [regex matchesInString:stringWithTags options:0 range:NSMakeRange(0, stringWithTags.length)];
    NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:stringWithTags];
    
    NSInteger stringLength=[stringWithTags length];
    
    for (NSTextCheckingResult *match in matches) {
        
        NSRange wordRange = [match rangeAtIndex:1];
        
        NSString* word = [stringWithTags substringWithRange:wordRange];
        
        //Set Font
        UIFont *font=[UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
        [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, stringLength)];
        
        
        //Set Background Color
        UIColor *backgroundColor=[UIColor orangeColor];
        [attString addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:wordRange];
        
        //Set Foreground Color
        UIColor *foregroundColor=[UIColor blueColor];
        [attString addAttribute:NSForegroundColorAttributeName value:foregroundColor range:wordRange];
        
        NSLog(@"Found tag %@", word);
        
        Pword = word;
        
        NSLog(@"the property is %@", Pword);
        
    }
    
    // Set up your text field or label to show up the result
    
    //    yourTextField.attributedText = attString;
    //
    //    yourLabel.attributedText = attString;
    
    return attString;

    
    
}


@end
