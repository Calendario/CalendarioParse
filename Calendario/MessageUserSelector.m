//
//  MessageUserSelector.m
//  Calendario
//
//  Created by Daniel Sadjadian on 22/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import "MessageUserSelector.h"

@interface MessageUserSelector ()

@end

@implementation MessageUserSelector

/// BUTTONS ///

-(IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/// VIEW DID LOAD ///

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set the search bar text color to white.
    [userSearchBar setTintColor:[UIColor whiteColor]];
    
    // Force open the keyboard.
    [userSearchBar becomeFirstResponder];
}

/// DATA METHODS ///

-(void)searchForUser:(NSString *)username {
    
    // Serup the user search query.
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" containsString:[username lowercaseString]];
    
    // Find any matching user profiles.
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (error == nil) {
            
            if ([objects count] > 0) {
                userData = [objects mutableCopy];
            } else {
                [userData removeAllObjects];
            }
            
        } else {
            [userData removeAllObjects];
        }
        
        [userList reloadData];
    }];
}

-(void)getUserCachedData:(NSString *)userID :(userCompletion)dataBlock {
    
    // Setup the user cache.
    static NSCache *userCache = nil;
    static dispatch_once_t onceToken;
    
    // Setup the cache object.
    
    dispatch_once(&onceToken, ^{
        userCache = [NSCache new];
    });
    
    // Access the user cache with the unique ID string.
    NSArray *cachedUserData = [userCache objectForKey:userID];
    
    // Check if the user data has been
    // previously stored in the cache.
    
    if (cachedUserData) {
        dataBlock(cachedUserData[0], cachedUserData[1]);
    }
    
    else {
        
        // Load the user profile data.
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" equalTo:userID];
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (error == nil) {
                
                // Download the user profile image.
                PFFile *userImageFile = object[@"profileImage"];
                [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    
                    if (error == nil) {
                        
                        // Set the profile image view.
                        UIImage *image = [UIImage imageWithData:imageData];
                        
                        // Save the user data in the cache.
                        [userCache setObject:@[[(PFUser *)object username], image] forKey:userID];
                        
                        dataBlock([(PFUser *)object username], image);
                        
                    } else {
                        dataBlock([(PFUser *)object username], nil);
                    }
                }];
                
            } else {
                dataBlock(nil, nil);
            }
        }];
    }
}

/// UITABLEVIEW METHODS ///

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Deselect the selected table view cell.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Close the user selector view.
    [self dismissViewControllerAnimated:YES completion:^{
        
        // Return the selected user object.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"user_selected_private_message" object:[userData objectAtIndex:indexPath.row]];
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Delegate call back for cell at index path.
    static NSString *CellIdentifier = @"MessageUserCell";
    MessageUserCell *cell = (MessageUserCell *)[userList dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageUserCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Get the current table view data object.
    PFUser *data = [userData objectAtIndex:indexPath.row];
    
    // Change the user pciture into a circle.
    CGPoint saveCenter = cell.profilePicture.center;
    CGRect newFrame = CGRectMake(cell.profilePicture.frame.origin.x, cell.profilePicture.frame.origin.y, 48.0, 48.0);
    cell.profilePicture.frame = newFrame;
    cell.profilePicture.layer.cornerRadius = (50.0 / 2.0);
    cell.profilePicture.center = saveCenter;
    
    // Get the other user's profile data.
    [self getUserCachedData:data.objectId :^(NSString *username, UIImage *picture) {
        
        if (picture == nil) {
            [cell.profilePicture setImage:[UIImage imageNamed:@"default_profile_pic.png"]];
        } else {
            [cell.profilePicture setImage:picture];
        }
        
        [cell.usernameLabel setText:username];
    }];
    
    // Set the cell selected background colour.
    UIView *selectedBackground = [[UIView alloc] init];
    [selectedBackground setBackgroundColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:0.3f]];
    [cell setSelectedBackgroundView:selectedBackground];
    
    // Set the content restraints.
    [cell.profilePicture setClipsToBounds:YES];
    [cell.usernameLabel setClipsToBounds:YES];
    [cell.contentView setClipsToBounds:NO];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Setup the initial cell properties before
    // the cell has been loaded and presented.
    cell.alpha = 0.0;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut animations:^{
        
        // Display the custom cell.
        cell.alpha = 1.0;
        
    } completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [userData count];
}

/// UISEARCHBAR METHODS ///

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    // Trim the search string text.
    NSString *searchString = [searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Check if the search is valid or not
    // before performing the search request.
    
    if (([searchString length] > 0) && (searchText != nil)) {
        [self searchForUser:searchText];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

/// OTHER METHODS ///

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
