//
//  NWDriversTableViewController.h
//  NickWeil
//
//  Created by Martin Skow Røed on 30.01.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//
// The DriverManager works exactly the same as the NWEventManager with the sorting. Read the details about NWEventManagerTableViewController.

#import <UIKit/UIKit.h>
#import "Driver.h"

@interface NWDriverManagerTableViewController : UITableViewController

@property (nonatomic) int eventId;
@property (strong, nonatomic) NSMutableArray *driverArray;
@property (strong, nonatomic) NSMutableArray *driverIndex;

- (void) initializeArrays; // Initializing the array, getting the full event from the database
- (void) initializeBarButtons;
- (void) setUpWithEventID:(int)evid; // called from DriverManager to set the event
- (void) didPressAddDriver; // Performing a segue, sending isNewDriver to NWDriverDetails
- (void) driverDidChange : (NSNotification *) note; // Invoked from NWDriverDetails, telling the controller that the driver has changed.

- (void) removeDriverFromArray : (NSIndexPath *)indexPath : (Driver *) driver; // Removing the driver from the array and database
@end
