//
//  SearchViewController.h
//  Calendario
//
//  Created by Larry B. King on 10/17/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchDisplayDelegate>

//UI properties
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (nonatomic, strong) UISearchController *searchController;

//User Properties
@property (nonatomic, strong) NSArray *allUsers;
@property (nonatomic, strong) NSMutableArray *friends;

//Parse Properties
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) PFRelation *friendsRelation;


@end
