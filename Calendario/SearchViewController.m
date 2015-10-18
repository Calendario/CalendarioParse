//
//  SearchViewController.m
//  Calendario
//
//  Created by Larry B. King on 10/17/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()
{
    NSMutableArray *filteredArray; 
}

@end

@implementation SearchViewController


- (void) viewWillAppear:(BOOL)animated
{
    //set current user
    self.currentUser = [PFUser currentUser];
    NSString *currentUsername = self.currentUser.username;
    
    //create predicate for filtering
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username != %@", currentUsername];
    
    
    //query ALL USERS and sort alphabetically.
    PFQuery *query = [PFUser queryWithPredicate:predicate];
    
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock: ^(NSArray *objects, NSError *error)
     {
         if (error)
         {
             NSLog(@"Error: %@ %@", error, [error userInfo]);
             
         }
         else
         {
             NSMutableArray *newArray = [[[NSMutableArray alloc] initWithArray:objects] mutableCopy];
             for (int i = 0; i < newArray.count; i++)
             {
                 PFUser *user = newArray[i];
                 
                 if ([self isFriend:user])
                 {
                     [newArray removeObject:user];
                     
                 }
                 
                 self.allUsers = newArray;
                 [self.editFriendsTableView reloadData];
             }
             
             /* self.allUsers = objects;
              [self.editFriendsTableView reloadData];*/
         }
         
     }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backButtonPressed:(id)sender {
}

#pragma mark Search Bar Methods
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [filteredArray removeAllObjects];
    
    NSString *searchString = self.searchController.searchBar.text;
    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"username == %@", searchString];
    filteredArray = [[self.friends filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    
    [self.removeTableView reloadData];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if ([self.searchController isActive])
    {
        return filteredArray.count;
    }
    else
    {
        
        return self.friends.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
    
    UILabel *userLabel = [cell.contentView viewWithTag:2];
    
}

//method to make sure there isn't an indention for uitableviewcell
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //row automatically deselects so it doesn't stay highlighted
    
}



@end
