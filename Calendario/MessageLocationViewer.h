//
//  MessageLocationViewer.h
//  Calendario
//
//  Created by Daniel Sadjadian on 29/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <CoreLocation/CoreLocation.h>

@interface MessageLocationViewer : UIViewController {
    
    // Main map view.
    IBOutlet MKMapView *mainMap;
    
    // Share text information.
    NSString *shareText;
    
    // Share bar button.
    IBOutlet UIBarButtonItem *shareButton;
    
    // Map control type.
    IBOutlet UISegmentedControl *mapControl;
}

// Buttons.
-(IBAction)done:(id)sender;
-(IBAction)share:(id)sender;
-(IBAction)viewDirections:(id)sender;
-(IBAction)changeMapType:(id)sender;

// UI methods.
-(void)viewAnnotationOnMap:(double)latitude :(double)longitude :(NSString *)dataTitle :(NSString *)dataSubtitle;

// Properties - strings, contacts, etc..
@property (nonatomic, retain) PFObject *passedInData;

@end
