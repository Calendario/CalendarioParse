//
//  TimelineCalendarViewController.h
//  Calendario
//
//  Created by Daniel Sadjadian on 23/11/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JTCalendar/JTCalendar.h>

@interface TimelineCalendarViewController : UIViewController <JTCalendarDelegate> {
    
}

// Reset calendar method.
-(void)resetEntireView;

// JTCalendar view properties.
@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTHorizontalCalendarView *calendarContentView;
@property (strong, nonatomic) JTCalendarManager *calendarManager;

@end
