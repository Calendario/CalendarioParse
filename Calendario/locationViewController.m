//
//  locationViewController.m
//  Calendario
//
//  Created by Larry B. King on 12/4/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

#import "locationViewController.h"
@import CoreLocation;
#import "AppDelegate.h"


@interface locationViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *testLabel;

@end

@implementation locationViewController
{
    GMSPlacesClient *placesClient;
    GMSPlace *currentPlace;
    
    NSMutableArray *locationsList;
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    placesClient = [[GMSPlacesClient alloc] init];
    locationsList = [NSMutableArray new];
    
}

- (IBAction)backPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma Mark Location Methods

- (IBAction)getPlace:(id)sender {
    [placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *placeLikelihoodList, NSError *error){
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
        self.testLabel.text = @"No current place";
       // self.addressLabel.text = @"";
        
        if (placeLikelihoodList != nil) {
            GMSPlace *place = [[[placeLikelihoodList likelihoods] firstObject] place];
            if (place != nil) {
                //self.nameLabel.text = place.name;
                self.testLabel.text = [[place.formattedAddress componentsSeparatedByString:@", "]
                                          componentsJoinedByString:@"\n"];
            }
        }
    }];
}

#pragma mark Table View Methods
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"locationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier forIndexPath:indexPath];
    
    
    return cell;
}

@end
