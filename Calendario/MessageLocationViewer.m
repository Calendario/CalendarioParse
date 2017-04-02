//
//  MessageLocationViewer.m
//  Calendario
//
//  Created by Daniel Sadjadian on 29/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import "MessageLocationViewer.h"

@interface MessageLocationViewer () {
    
    // Location data object.
    PFGeoPoint *location;
}

@end

@implementation MessageLocationViewer
@synthesize passedInData;

/// BUTTONS ///

-(IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)share:(id)sender {
    
    // Ensure the share data is valid.
    
    if (shareText != nil) {
        
        // Create the share view controller.
        UIActivityViewController *shareView = [[UIActivityViewController alloc] initWithActivityItems:@[shareText] applicationActivities:nil];
        
        // Set the completion handler action.
        shareView.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {};
        
        // Show the share view controller.
        [self presentViewController:shareView animated:YES completion:^{}];
    }
}

-(IBAction)viewDirections:(id)sender {
    
    // Create the Apple Maps iOS app URL.
    NSString *appleMapsURL = [NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@&saddr=current%%20location", [NSString stringWithFormat:@"%f%%2c%f", [location latitude], [location longitude]]];
    
    // Open directions in the Apple Maps iOS app.
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appleMapsURL] options:@{} completionHandler:nil];
}

-(IBAction)changeMapType:(id)sender {
    
    // Set the map display type.
    
    if (mapControl.selectedSegmentIndex == 0) {
        [mainMap setMapType:MKMapTypeStandard];
    }
    
    else if (mapControl.selectedSegmentIndex == 1) {
        [mainMap setMapType:MKMapTypeSatellite];
    }
    
    else {
        [mainMap setMapType:MKMapTypeHybrid];
    }
}

/// VIEW DID LOAD ///

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Disable the share button until
    // the location data has been loaded.
    [shareButton setEnabled:NO];
    
    // Get the location data.
    location = [passedInData valueForKey:@"locationData"];
    
    // Initialise the location geocoder.
    CLGeocoder *locationGeocoder = [[CLGeocoder alloc] init];
    
    // Convert the start coordinates into an address.
    [locationGeocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:[location latitude] longitude:[location longitude]] completionHandler:^(NSArray *placemarks, NSError *error) {
        
        // Ensure there are no errors.
        
        if (error == nil) {
            
            // Get start point address.
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            
            // Get the address string.
            NSString *address = [[placemark.addressDictionary objectForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            
            // Set the share text data (address + co-ordinates).
            shareText = [NSString stringWithFormat:@"%@\n\n%f, %f", address, location.latitude, location.longitude];
            
            // Enable the share button.
            [shareButton setEnabled:YES];
            
            // View the annotation on the map.
            [self viewAnnotationOnMap:location.latitude :location.longitude :address :[NSString stringWithFormat:@"%f, %f", location.latitude, location.longitude]];
        }
        
        else {
            
            // Set the share text data.
            shareText = [NSString stringWithFormat:@"%f, %f", location.latitude, location.longitude];
            
            // Enable the share button.
            [shareButton setEnabled:YES];
            
            // View the annotation on the map.
            [self viewAnnotationOnMap:location.latitude :location.longitude :[NSString stringWithFormat:@"%f", location.latitude] :[NSString stringWithFormat:@"%f", location.longitude]];
        }
    }];
}

/// UI METHODS ///

-(void)viewAnnotationOnMap:(double)latitude :(double)longitude :(NSString *)dataTitle :(NSString *)dataSubtitle {
    
    // Create the co-ordiantes object.
    CLLocationCoordinate2D coord;
    coord.latitude = latitude;
    coord.longitude = longitude;
    
    // Create the map region.
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;
    region.span = span;
    region.center = coord;
    
    // Create the map annotation pin.
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    [pin setTitle:dataTitle];
    [pin setSubtitle:dataSubtitle];
    [pin setCoordinate:coord];
    
    // Add the pin to the map.
    [mainMap addAnnotation:pin];
    
    // Zoom the map to area of the pin.
    [mainMap setRegion:region animated:NO];
    
    // Ensure that the zoom area fits the map size.
    [mainMap regionThatFits:region];
    
    // Force open the annotation popup.
    [mainMap selectAnnotation:pin animated:YES];
}

/// OTHER METHODS ///

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
