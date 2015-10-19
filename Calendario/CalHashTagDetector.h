//
//  CalHashTagDetector.h
//  Calendario
//
//  Created by Derek Cacciotti on 10/19/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

#import <Foundation/Foundation.h>
  #import <UIKit/UIKit.h>

@interface CalHashTagDetector : NSObject

-(NSMutableAttributedString*)decorateTags:(NSString *)stringWithTags;

@end

