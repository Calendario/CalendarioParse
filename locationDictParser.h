//
//  locationDictParser.h
//  Calendario
//
//  Created by Daniel Sadjadian on 17/11/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^parseCompletion)(double latitude, double longitude);

@interface locationDictParser : NSObject {
    
}

// Data methods.
-(void)parseLocationSearchDict:(NSDictionary *)searchData :(parseCompletion)block;

@end
