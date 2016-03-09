//
//  SearchViewController.m
//  Calendario
//
//  Created by Larry B. King on 10/17/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

#import "SearchViewController.h"
#import "Calendario-Swift.h"

@interface SearchViewController ()
{
    NSMutableArray *filteredArray;
    NSMutableArray *searchedData;
    NSArray *newFilteredArray;
    BOOL isFiltered;
}

@end

@implementation SearchViewController

- (void) viewWillAppear:(BOOL)animated
{
    //set current user
    self.currentUser = [PFUser currentUser];
    
    //query ALL USERS and sort alphabetically.
    PFQuery *query = [PFUser query];

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
                   //do nothing
                 }
                 self.allUsers = newArray;
                 [self.searchTableView reloadData];
             }
        }
     }];
    
    self.tabBarController.hidesBottomBarWhenPushed = YES;
    [self.searchTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //add search bar to tableview header
    self.searchTableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    //create filtered array
    filteredArray = [[NSMutableArray alloc] init];
    
    [self setupUI];
    [self setDataSources];
    [self setDelegates];
}

- (void) setupUI {
    //configure search controller
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    
    //set searchbar properties
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.translucent = NO;

    //set search bar icon color
    [self.searchController.searchBar setImage:[UIImage imageNamed:@"search_icon"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];

    //hide 1px black line above searchbar
    self.searchController.searchBar.layer.borderColor = [UIColor colorWithRed:33/255.0f green:135/255.0f blue:75/255.0f alpha:1.0].CGColor;
    self.searchController.searchBar.layer.borderWidth = 1;
    
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

}

- (void) setDataSources{
     self.searchTableView.dataSource = self;
}

- (void) setDelegates{
    self.searchTableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
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

- (void) showProfileView: (PFUser *)user {
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MyProfileViewController *profVC = [mainSB instantiateViewControllerWithIdentifier:@"My Profile"];
    profVC.passedUser = user;
    profVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:profVC animated:YES completion:NULL];
}

#pragma mark Search Bar Methods
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    [filteredArray removeAllObjects];
    
    NSString *searchString = self.searchController.searchBar.text;
    
    //NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"username == %@", searchString];  <-- for exact match
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"username contains[c] %@", searchString]; //<-- so tableview loads while user is typing
    
    filteredArray = [[self.allUsers filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    
    [self.searchTableView reloadData];
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //force lowercase typing
    searchBar.text = searchText.lowercaseString;
    
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchTableView.backgroundView = nil;
    self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.searchTableView reloadData];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    /*self.searchTableView.backgroundView = nil;
    self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.searchTableView reloadData];*/
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if (filteredArray.count < 1)
    {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"user not found";
        messageLabel.textColor = [UIColor darkGrayColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont systemFontOfSize:16];
        [messageLabel sizeToFit];
        
        self.searchTableView.backgroundView = messageLabel;
        self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.searchTableView reloadData];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (filteredArray.count > 0)
    {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
    return 3;
    }
    else {
    if ([self.searchController isActive])
    {
        return filteredArray.count;
    }
    return 0;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(31, view.frame.size.height/2, tableView.frame.size.width, 18)];
    [title setFont:[UIFont fontWithName:@"SF-UI-Display-Medium" size:16.0]];
    UIImageView *headerIcon = [[UIImageView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    if (section == 0) {
        title.text = @"SUGGESTED USERS";
        headerIcon.image = [UIImage imageNamed: @"star-icon.png"];
    }
    else {
        title.text = @"SEARCH RESULTS";
        headerIcon.image = [UIImage imageNamed: @"clock-icon.png"];
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
    
    cell.userInteractionEnabled = NO;
    
    UILabel *userLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:4];
    UIImageView *userImage = (UIImageView *)[cell.contentView viewWithTag:1];
    UIImageView *ribbonImage = (UIImageView *) [cell.contentView viewWithTag:3];
    UIImage *notAvailable = [UIImage imageNamed:@"default_profile_pic.png"];
    userImage.image = notAvailable;
    
    //hide elements
    userLabel.hidden = YES;
    userImage.hidden = YES;
    nameLabel.hidden = YES;
    
    if ([self.searchController isActive])
    {
        PFUser *user = [filteredArray objectAtIndex:indexPath.row];
        userLabel.hidden = NO;
        userImage.hidden = NO;
        nameLabel.hidden = NO;
        cell.userInteractionEnabled = YES;
        userLabel.text = user.username;
        
        NSString *name = [user valueForKey:@"fullName"];
        if ((name != nil) && (name.length > 0)) {
            nameLabel.text = name;
        }
        
        //check if user is verified and display ribbon
        BOOL verified = [user valueForKey:@"verifiedUser"];
        if (verified == true) {
            ribbonImage.hidden = NO;
        }
        else
        {
            ribbonImage.hidden = YES;
        }
        
        //fetch user profile image for table cell
        PFFile *userImageFile = user[@"profileImage"];
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (!error)
             {
                 UIImage *image = [UIImage imageWithData:imageData];
                 
                 [userImage setImage:image];
                 userImage.layer.cornerRadius = userImage.frame.size.width/2;
                 userImage.clipsToBounds = YES;
                 userImage.layer.borderWidth = 1.0f;
                 userImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
             }
             else
             {
                 NSLog(@"%@", [error localizedDescription]);
             }
             
         }];
        return cell;
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
    [self.searchTableView reloadData];
    
    // GET THE PF USER DATA OBJECT.
    PFUser *user = [filteredArray objectAtIndex:indexPath.row];
    [self showProfileView:user];
}

@end
