//
//  ThreadDataObject.h
//  Calendario
//
//  Created by Daniel Sadjadian on 02/04/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ThreadDataObject : NSObject {
    
}

// Properties - strings, URLs, etc..
@property (strong, nonatomic) PFObject *threadObject;
@property (strong, nonatomic) PFObject *latestMessage;
@property (strong, nonatomic) NSNumber *unreadCount;

@end
