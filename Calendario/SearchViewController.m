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
    NSMutableArray *searchedData;
    BOOL isFiltered;

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
                 [self.searchTableView reloadData];
             }
             
             /* self.allUsers = objects;
              [self.editFriendsTableView reloadData];*/
         }
         
     }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.searchTableView.dataSource = self;
    self.searchTableView.delegate = self;
    
    //configure search controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchResultsUpdater = self;

    
    //override default background color of searchbar's textfield
    for (UIView *subView in self.searchController.searchBar.subviews)
    {
        for (UIView *secondLevelSubview in subView.subviews){
            if ([secondLevelSubview isKindOfClass:[UITextField class]])
            {
                UITextField *searchBarTextField = (UITextField *)secondLevelSubview;
                
                //set font color here
                searchBarTextField.backgroundColor = [UIColor colorWithRed:24/255.0f green:99/255.0f blue:56/255.0f alpha:1.0];
                searchBarTextField.textColor = [UIColor whiteColor];
                break;
            }
        }
    }
    
    //set searchbar properties
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.backgroundColor = [UIColor colorWithRed:33/255.0f green:135/255.0f blue:75/255.0f alpha:1.0];
    self.searchController.searchBar.barTintColor = [UIColor colorWithRed:33/255.0f green:135/255.0f blue:75/255.0f alpha:1.0];
    self.searchController.searchBar.tintColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0];
    self.searchController.searchBar.translucent = NO;

    
    //set searchBar Text color
    for (UIView *subview in self.searchController.searchBar.subviews) {
        for (UIView *sv in subview.subviews) {
            if ([NSStringFromClass([sv class]) isEqualToString:@"UISearchBarTextField"]) {
                
                if ([sv respondsToSelector:@selector(setAttributedPlaceholder:)]) {
                    ((UITextField *)sv).attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.searchController.searchBar.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
                }
                break;
            }
        }
    }
    
    //set search bar icon color
    [self.searchController.searchBar setImage:[UIImage imageNamed:@"search_icon"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    //hide 1px black line above searchbar
    self.searchController.searchBar.layer.borderColor = [UIColor colorWithRed:33/255.0f green:135/255.0f blue:75/255.0f alpha:1.0].CGColor;
    self.searchController.searchBar.layer.borderWidth = 1;
    



    self.searchTableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    
    filteredArray = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) isFriend:(PFUser *)user
{
    for (PFUser *friend in self.friends)
    {
        if ([friend.objectId isEqualToString:user.objectId])
        {
            return YES;
        }
        
        
    }
    return NO;
}



- (IBAction)backButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark Search Bar Methods
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [filteredArray removeAllObjects];
    
    NSString *searchString = self.searchController.searchBar.text;
    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"username == %@", searchString];
    filteredArray = [[self.allUsers filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    
    [self.searchTableView reloadData];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //force lowercase typing
    searchBar.text = searchText.lowercaseString;
    
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
        
        return self.allUsers.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
    
    UILabel *userLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UIImageView *userImage = (UIImageView *)[cell.contentView viewWithTag:1];
    UIImage *notAvailable = [UIImage imageNamed:@"notAvailable_icon.png"];
    userImage.image = notAvailable;
    
    //hide elements
    userLabel.hidden = YES;
    userImage.hidden = YES;
    
    if ([self.searchController isActive])
    {
        PFUser *user = [filteredArray objectAtIndex:indexPath.row];
        userLabel.hidden = NO;
        userImage.hidden = NO;
        userLabel.text = user.username;
        
        //fetch user profile image for table cell
        PFFile *userImageFile = user[@"profileImage"];
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                [userImage setImage:image];
                userImage.layer.cornerRadius = userImage.frame.size.width/2;
                userImage.clipsToBounds = YES;
                userImage.layer.borderWidth = 1.0f;
                userImage.layer.borderColor = [UIColor lightGrayColor].CGColor;

            }
        }];
        
        
        return cell;
    }
    
    else
    {
        /*PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
        userLabel.text = user.username;
        
        //NEED TO IMPLEMENT USER PROFILE IMAGE ONCE AVAILABLE****
        
        PFFile *userImageFile = user[@"profileImage"];
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                [userImage setImage:image];
                userImage.layer.cornerRadius = userImage.frame.size.width/2;
                userImage.clipsToBounds = YES;
                userImage.layer.borderWidth = 1.0f;
                userImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
                
            }
        }];
        
        return cell;*/
    }
    
    
    return cell;
    
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
    [self.searchTableView deselectRowAtIndexPath:indexPath animated:NO];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
    
    //NAVIGATE TO SELECTED USER'S PROFILE PAGE
    
}



@end
