//
//  DBHandler.h
//  NickWeil
//
//  Created by Martin Skow Røed on 31.01.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//
// A shared manager which takes care of all the connection with the SQLite database. Another manager will take care of the MySQL database handling when that time comes.

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "Event.h"
#import "Driver.h"

@interface DBHandler : NSObject

@property (nonatomic) NSString * databasePath;

+ (DBHandler *)sharedManager; // Returning a shared DBHandler instance

- (void) deleteDatabaseFromPhone; // Deleted the database from the phone to update it from the resourcefolder. Commented out by default, mainly for debugging.
- (void) createAndCheckDatabase; // Checking the database exists, if it doesn't, we copy it from the resourcesfolder, mainly for debugging

- (NSMutableArray *) getAllShortEvents; // Returning an array with events with the ID and NAME only.
- (NSMutableArray *) getAllShortDriversWithEventID : (int) eventID; // Returning drivers with IDS and name only.

- (Event *) getWholeEventFromShortEvent : (Event *) shortevent; // Returning the whole event from the short event describer over.
- (Driver *) getWholeDriverFromShortDriver : (Driver *) shortdriver; // Returning the whole driver with all its properties from the short one.

- (Event *) createNewEvent; // When pressing Add Event, it creates a new entry in the database and return the Event with an ID ready to be updated.
- (Driver *) createNewDriverWithEventId : (int) eventId; // Creating a driver with a specific eventid, returning a 'short driver'.

- (Driver *) createNewDriverWithDriverId:(int)driverId andEventId:(int) eventId;
- (void) updateEvent : (Event *) event; // Updating an event in the database
- (void) updateDriver : (Driver *) driver; // Updating driver with the details edited in NWDriverDetails

- (void) deleteDriver : (Driver *) driver; // Deleting a driver from the database
- (void) deleteEvent : (Event *) event; // Deleting an event from the database

- (BOOL) hasDuplicate:(NSString *)someid inEvent:(int) eventId andType:(int) type;

- (Driver *) getDriverFromBarcode: (NSString *)barcode;

- (void) storeEventFromDatabaseWithJson : (id) JSON andEvent:(Event *)event;
- (void) storeEventFromDatabaseWithJson:(id)JSON;
- (void) storeDriversFromDatabaseWithJSON:(id)JSON andEventID:(int)eventID;

- (NSArray *) getClassesFromEventID:(int) eventId;

@end