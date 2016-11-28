//
//  TimelineCalendarViewController.m
//  Calendario
//
//  Created by Daniel Sadjadian on 23/11/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

#import "TimelineCalendarViewController.h"
#import <Parse/Parse.h>
#import "SAMCache.h"

@interface TimelineCalendarViewController () {
    
    // User selected date.
    NSDate *selectedDate;
    
    // Dot data cache.
    SAMCache *dotCache;
}

@end

@implementation TimelineCalendarViewController

//MARK: VIEW DID LOAD.

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialise the data cache.
    dotCache = [SAMCache sharedCache];
    
    // Clear the cache of any old data.
    [dotCache removeAllObjects];
    
    // Create the calander manager class object.
    self.calendarManager = [JTCalendarManager new];
    self.calendarManager.delegate = self;
    
    // Setup the calendar view.
    [self.calendarManager setMenuView:self.calendarMenuView];
    [self.calendarManager setContentView:self.calendarContentView];
    [self.calendarManager setDate:[NSDate date]];
}

//MARK: VIEW DID APPEAR.

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    // Check if we need to load the current
    // calendar date or the selected date.
    
    if (selectedDate == nil) {
        
        // Load the current months dot data.
        [self loadDotDataWithDate:[NSDate date]];
        
        // Load the events for the current date.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CalenderDateSelected" object:[NSDate date]];
        
    } else {
        
        // Load the last selected date.
        [self loadDotDataWithDate:selectedDate];
        
        // Load the events for the selected date.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CalenderDateSelected" object:selectedDate];
    }
}

//MARK: DATA METHODS.

-(void)loadDotDataWithDate:(NSDate *)date {
    
    // Convert the input date into a date component object.
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    
    // Get the month and year string from the input date.
    NSString *monthString = [NSString stringWithFormat:@"%ld", (long)[components month]];
    NSString *yearString = [[NSString stringWithFormat:@"%01ld", (long)[components year]] substringFromIndex:2];
    
    // Loop through the cache dot data.
    
    for (int loop = 1; loop < 33; loop++) {
        
        // Create the loop date string.
        NSString *dateString = [NSString stringWithFormat:@"%@/%d/%@", monthString, loop, yearString];
        
        // Initialise the dot check to 'NO'.
        dotCache[dateString] = @"NO";
    }
    
    // Ensure the user is logged in
    // before loading the dot data.
    
    if ([PFUser currentUser] != nil) {
        
        // Set the dot depending on the number of events for the date.
        [PFCloud callFunctionInBackground:@"getMonthDotData" withParameters:@{@"inputEventMonth": monthString, @"inputEventYear": yearString, @"user": [[PFUser currentUser] objectId]} block:^(NSArray *objects, NSError *error) {
            
            if (error == nil) {
                
                // Loop through any returned status updates and
                // set the cooresponding date dot checks to 'YES'.
                
                for (NSUInteger loop = 0; loop < [objects count]; loop++) {
                    dotCache[[(PFObject *)objects[loop] valueForKey:@"dateofevent"]] = @"YES";
                }
            }
            
            // Update the calendar view.
            [self.calendarManager reload];
        }];
    } else {
        
        // Clear the calendar as the usrr has signed out.
        [self.calendarManager reload];
    }
}

//NARK: OTHER METHODS.

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//MARK: JTCALENDAR METHODS.

-(void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView {
    
    // Set the default day label alpha.
    [dayView setAlpha:1.0];
    
    // Set the various different UI object proerties depending
    // on the current date, selected date and other attributes.
    
    if ([dayView isFromAnotherMonth]) {
        [dayView setAlpha:0.3];
    }
    
    else if ([self.calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]) {
        
        // Today date settings.
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    else if (selectedDate && [self.calendarManager.dateHelper date:selectedDate isTheSameDayThan:dayView.date]) {
        
        // Selected date settings.
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    else {
        
        // Another day of the current month.
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    
    // Convert the calender into a date component object.
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear) fromDate:dayView.date];
    
    // Create the dot cache check date string - MM/DD/YY.
    NSString *dateString = [NSString stringWithFormat:@"%ld/%ld/%@", (long)[components month], (long)[components day], [[NSString stringWithFormat:@"%01ld", (long)[components year]] substringFromIndex:2]];
    
    // If data has been cached then check it
    // otherwise hide the dot view for now.
    
    if ([dotCache objectExistsForKey:dateString] == YES) {
        
        // Show or hide the dot view depending
        // on the state of the cached date item.
        
        if ([[dotCache objectForKey:dateString] isEqualToString:@"YES"]) {
            dayView.dotView.hidden = NO;
        } else {
            dayView.dotView.hidden = YES;
        }
        
    } else {
        dayView.dotView.hidden = YES;
    }
}

-(void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar {
    [self loadDotDataWithDate:calendar.date];
}

-(void)calendarDidLoadNextPage:(JTCalendarManager *)calendar {
    [self loadDotDataWithDate:calendar.date];
}

-(void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView {

    // Set the selected date.
    selectedDate = dayView.date;
    
    // Animation for the circleView.
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction) animations:^{
        dayView.circleView.transform = CGAffineTransformIdentity;
        [self.calendarManager reload];
    } completion:^(BOOL finished) { }];
    
    // Load the previous or next page if touch a day from another month
    if (![self.calendarManager.dateHelper date:self.calendarContentView.date isTheSameMonthThan:dayView.date]) {
        
        if([self.calendarContentView.date compare:dayView.date] == NSOrderedAscending) {
            [self.calendarContentView loadNextPageWithAnimation];
        } else {
            [self.calendarContentView loadPreviousPageWithAnimation];
        }
    }
    
    // Load the events for the selected date.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CalenderDateSelected" object:selectedDate];
}

-(UIView *)calendarBuildMenuItemView:(JTCalendarManager *)calendar {
    
    // Create and customise the month label.
    UILabel *label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"SFUIDisplay-Light" size:18];
    
    return label;
}

-(UIView *)calendarBuildWeekDayView:(JTCalendarManager *)calendar {
    
    // Create and customise the day labels (MON/TUE....SUN).
    JTCalendarWeekDayView *view = [JTCalendarWeekDayView new];
    
    // Set the label colour and fonts.
    
    for (NSUInteger loop = 0; loop < [view.dayViews count]; loop++) {
        [((UILabel *)view.dayViews[loop]) setTextColor:[UIColor colorWithWhite:1.0 alpha:0.7]];
        [((UILabel *)view.dayViews[loop]) setFont:[UIFont fontWithName:@"SFUIDisplay-Light" size:15]];
    }
    
    return view;
}

-(UIView<JTCalendarDay> *)calendarBuildDayView:(JTCalendarManager *)calendar {
    
    // Create and customise the calendar view.
    JTCalendarDayView *view = [JTCalendarDayView new];
    view.textLabel.font = [UIFont fontWithName:@"SFUIDisplay-Light" size:15];
    view.textLabel.textColor = [UIColor whiteColor];
    
    return view;
}

//MARK: COMPLETE RESET METHODS.

-(void)resetEntireView {
    
    // This method is called when the user taps
    // the 'Sign Out' button in the settings view.
    [dotCache removeAllObjects];
    selectedDate = nil;
    [self loadDotDataWithDate:[NSDate date]];
}

@end
