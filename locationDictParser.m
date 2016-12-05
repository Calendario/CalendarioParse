//
//  locationDictParser.m
//  Calendario
//
//  Created by Daniel Sadjadian on 17/11/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

#import "locationDictParser.h"
#import "Calendario-Swift.h"

@implementation locationDictParser

/// DATA METHODS ///

-(void)parseLocationSearchDict:(NSDictionary *)searchData :(parseCompletion)block {
    
    // Get the location data object.
    id location = [[[searchData objectForKey:@"results"] valueForKey:@"geometry"] valueForKey:@"location"];
    
    // Create the latitude/longitude values.
    double coordinate_lat;
    double coordinate_lon;
    
    @try {
        
        // Set the latitude/longitude values.
        coordinate_lat = [[[location valueForKey:@"lat"] objectAtIndex:0] doubleValue];
        coordinate_lon = [[[location valueForKey:@"lng"] objectAtIndex:0] doubleValue];
        
    } @catch (NSException *exception) {
        
        // Unable to get latitude/longitude.
        coordinate_lat = 0.00000;
        coordinate_lon = 0.00000;
        
    } @finally {
        
        // Return the location data.
        block(coordinate_lat, coordinate_lon);
    }
}

@end
