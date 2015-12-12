//
//  notificationsTableViewController.h
//  Calendario
//
//  Created by Larry B. King on 12/11/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface notificationsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *notificationsTableView;

@end
