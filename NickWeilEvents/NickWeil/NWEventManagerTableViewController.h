//
//  NWEventManagerTableViewController.h
//  NickWeil
//
//  Created by Martin Skow Røed on 28.01.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//
// Lists all the events, sorted alphabetically with sections, using to arrays, one eventArray and one eventIndex. The eventIndex is an unique array holding the first char of all the eventnames. This is used for sectiontitles. Searching in the array is done by using simple predicates on the event's name.

#import <UIKit/UIKit.h>
#import "Event.h"

@interface NWEventManagerTableViewController : UITableViewController <UITabBarControllerDelegate, UITabBarDelegate>
@property (strong, nonatomic) NSMutableArray *eventArray;
@property (strong, nonatomic) NSMutableArray *eventIndex;


- (void) initializeArrays; //initializing the array for sorted tableview
- (void) initializeBarButtons; // setting up the right bar button
- (void) didPressAddEvent; // not implemented yet
- (void) eventDidChange : (NSNotification *) note; // invoked from the NWEventDetailsViewcontroller
- (void) removeEventFromArray : (NSIndexPath *) indexPath : (Event *) ev; // Remove the event from the array

@end
