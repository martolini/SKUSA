//
//  DBHandler.m
//  NickWeil
//
//  Created by Martin Skow Røed on 31.01.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import "DBHandler.h"
#import "Event.h"
#import "Driver.h"

@implementation DBHandler

NSString * const databaseName = @"maindb.sqlite";

+ (DBHandler *)sharedManager {
    static DBHandler *instance = nil;
    if (instance == nil) {
        instance = [[DBHandler alloc] init];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsPath = [paths objectAtIndex:0];
        instance.databasePath = [docsPath stringByAppendingPathComponent:databaseName];
        
//        [instance deleteDatabaseFromPhone];
        
        [instance createAndCheckDatabase];
    }
    return instance;
}

-(void) createAndCheckDatabase {
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:self.databasePath];
    
    if(success)
        return;
    NSLog(@"copied database");
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
    
    [fileManager copyItemAtPath:databasePathFromApp toPath:self.databasePath error:nil];
}

- (void) deleteDatabaseFromPhone  { //DEBUG
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directory = [paths objectAtIndex:0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"maindb.sqlite"];
    BOOL fileDeleted = [fileManager removeItemAtPath:filePath error:&error];
    if (fileDeleted)
        NSLog(@"sucessfully removed the database");
    else NSLog(@"could not remove database, %@", error);
}

- (NSMutableArray *) getAllShortEvents {
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open]) {
        NSLog(@"error");
        return nil;
    }
    FMResultSet *results = [db executeQuery:@"SELECT name, eventid FROM event"];
    NSMutableArray *events = [[NSMutableArray alloc] init];
    while ([results next]) {
        Event *event = [[Event alloc] init];
        [event setName:[results stringForColumn:@"name"]];
        [event setEventid:[results intForColumn:@"eventid"]];
        [events addObject:event];
    }
    [db close];
    NSArray *sortedEvents = [events sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(Event *)a name];
        NSString *second = [(Event *)b name];
        return [first compare:second];
    }];
    return [sortedEvents mutableCopy];
}

- (Event *) getWholeEventFromShortEvent:(Event *)shortevent {
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open]) {
        NSLog(@"error");
        return nil;
    }
    FMResultSet *result = [db executeQuery:@"SELECT * FROM event where eventid = ?", [NSNumber numberWithInt:[shortevent eventid]]];
    Event *event = [[Event alloc] init];
    while ([result next]) {
        [event setEventid:[result intForColumn:@"eventid"]];
        [event setName:[result stringForColumn:@"name"]];
        [event setOrganization:[result stringForColumn:@"organization"]];
        [event setLocation:[result stringForColumn:@"location"]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        [event setStartDate:[formatter dateFromString:[result stringForColumn:@"start"]]];
        [event setEndDate:[formatter dateFromString:[result stringForColumn:@"end"]]];
        [event setClasses:[NSMutableArray arrayWithArray:[[result stringForColumn:@"classes"] componentsSeparatedByString:@","]]];
    }
    [db close];
    return event;
}

- (NSMutableArray *) getAllShortDriversWithEventID : (int) eventID {
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open]) {
        NSLog(@"error");
        return nil;
    }
    FMResultSet *results = [db executeQuery:@"SELECT name, driverid, tires FROM driver where eventid = ?", [NSNumber numberWithInt:eventID]];
    NSMutableArray *drivers = [[NSMutableArray alloc] init];
    while ([results next]) {
        Driver *driver = [[Driver alloc] init];
        [driver setDriverid:[results intForColumn:@"driverid"]];
        [driver setName:[results stringForColumn:@"name"]];
        NSString *tiresString = [results stringForColumn:@"tires"];
        if ([tiresString isEqualToString:@""] || tiresString == nil)
            [driver setTires:[NSMutableArray array]];
        else [driver setTires:[[tiresString componentsSeparatedByString:@","] mutableCopy]];
        [drivers addObject:driver];
    }
    [db close];
    NSArray *sortedDrivers = [drivers sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(Driver *)a name];
        NSString *second = [(Driver *)b name];
        return [first compare:second];
    }];
    return [sortedDrivers mutableCopy];
}

- (void) updateEvent:(Event *)event {
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open])
        NSLog(@"Error");
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *query = [NSString stringWithFormat:@"UPDATE event SET name=%@, location=%@, organization=%@, start=%@, end=%@, classes=%@ WHERE eventid=%i",
                       [event name],
                       [event location],
                       [event organization],
                       [formatter stringFromDate:[event startDate]],
                       [formatter stringFromDate:[event endDate]],
                       [event.classes componentsJoinedByString:@","],
                       event.eventid
                       ];
    [db executeUpdate:query];
    [db close];
}

- (Event *) createNewEvent {
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open])
        NSLog(@"Error");
    [db executeUpdate:@"INSERT INTO event (name) VALUES (?)", @"New event"];
    Event *event = [[Event alloc] init];
    event.eventid = [db lastInsertRowId];
    event.name = @"New event";
    event.classes = [NSMutableArray array];
    [db close];
    return event;
}

- (Driver *) getWholeDriverFromShortDriver:(Driver *)shortdriver{
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open])
        NSLog(@"error");
    FMResultSet *results = [db executeQuery:@"SELECT * from driver where driverid = ?", [NSNumber numberWithInt:[shortdriver driverid]]];
    Driver *driver = [[Driver alloc] init];
    while ([results next]) {
        [driver setDriverid:[results intForColumn:@"driverid"]];
        [driver setDriverclass:[results stringForColumn:@"class"]];
        [driver setName:[results stringForColumn:@"name"]];
        [driver setKart:[results stringForColumn:@"kart"]];
        [driver setAMB:[results stringForColumn:@"AMB"]];
        [driver setNote:[results stringForColumn:@"note"]];
        
        NSString *tiresString = [results stringForColumn:@"tires"];
        if ([tiresString isEqualToString:@""] || tiresString == nil)
            [driver setTires:[NSMutableArray array]];
        else [driver setTires:[[tiresString componentsSeparatedByString:@","] mutableCopy]];
        
        NSString *chassisString = [results stringForColumn:@"chassis"];
        if ([chassisString isEqualToString:@""] || chassisString == nil)
            [driver setChassis:[NSMutableArray array]];
        else [driver setChassis:[[chassisString componentsSeparatedByString:@","] mutableCopy]];
        
        NSString *enginesString = [results stringForColumn:@"engines"];
        if ([enginesString isEqualToString:@""] || enginesString == nil)
            [driver setEngines:[NSMutableArray array]];
        else [driver setEngines:[[enginesString componentsSeparatedByString:@","] mutableCopy]];
        
        [driver setEventid:[results intForColumn:@"eventid"]];
    }
    [db close];
    return driver;
}

- (void) updateDriver:(Driver *)driver {
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open])
        NSLog(@"error");
    NSString *query = [NSString stringWithFormat:@"UPDATE driver SET name='%@', class='%@', kart='%@', note='%@', tires='%@', chassis='%@', engines='%@' WHERE driverid=%i",
                       driver.name,
                       driver.driverclass,
                       driver.kart,
                       driver.note,
                       [[driver tires] componentsJoinedByString:@","],
                       [[driver chassis] componentsJoinedByString:@","],
                       [[driver engines] componentsJoinedByString:@","],
                       driver.driverid];
    [db executeUpdate:query];
    [db close];
}

- (Driver *) createNewDriverWithEventId : (int) eventId {
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open])
        NSLog(@"error");
    [db executeUpdate:@"INSERT INTO driver (name, eventid) VALUES (?, ?) ", @"New Driver", [NSNumber numberWithInt:eventId]];
    Driver *driver = [[Driver alloc] init];
    driver.driverid = db.lastInsertRowId;
    driver.name = @"New Driver";
    driver.eventid = eventId;
    [db close];
    
    return driver;
}

- (Driver *) createNewDriverWithDriverId:(int)driverId andEventId:(int) eventId {
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open])
        NSLog(@"error");
    NSString *query = [NSString stringWithFormat:@"INSERT INTO driver (driverid, name, class, eventid, tires, chassis, engines) VALUES (%i, 'NewDriver', 'None', %i, '','', '');", driverId, eventId];
    BOOL success = [db executeUpdate:query];
    if (!success) {
        NSLog(@"error = %@", [db lastErrorMessage]);
    }
    Driver *driver = [[Driver alloc] init];
    driver.driverid = driverId;
    driver.name = @"New Driver";
    driver.eventid = eventId;
    [driver setTires:[NSMutableArray array]];
    [driver setChassis:[NSMutableArray array]];
    [driver setEngines:[NSMutableArray array]];
    [db close];
    return driver;
}

- (void) deleteDriver:(Driver *)driver {
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open])
        NSLog(@"error");
    [db executeUpdate:@"DELETE FROM driver WHERE driverid=?", [NSNumber numberWithInt:driver.driverid]];
    [db close];
}

- (void) deleteEvent:(Event *)event {
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open])
        NSLog(@"error");
    [db executeUpdate:@"DELETE FROM event WHERE eventid=?", [NSNumber numberWithInt:event.eventid]];
    [db close];
}

- (BOOL) hasDuplicate:(NSString *)someid inEvent:(int) eventId andType:(int)type{
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open])
        NSLog(@"error");
    NSString *table = @"";
    switch (type) {
        case 0:
            table = @"tires";
            break;
        case 1:
            table = @"chassis";
            break;
        default:
            table = @"engines";
            break;
    }
    NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM driver WHERE eventid=%i", table, eventId];
    FMResultSet *results = [db executeQuery:query];
    while ([results next]) {
        NSString *str = [results objectForColumnName:table];
        if ([[str componentsSeparatedByString:@","] containsObject:someid])
            return YES;
    }
    return NO;
}

- (Driver *)getDriverFromBarcode:(NSString *)barcode {
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open]) {
        NSLog(@"error");
        return nil;
    }
    FMResultSet *results = [db executeQuery:@"SELECT * FROM driver"];
    while ([results next]) {
        NSMutableArray *bigArray = [NSMutableArray array];
        NSString *tiresString = [results stringForColumn:@"tires"];
        if (!([tiresString isEqualToString:@""] || tiresString == nil))
            [bigArray addObject:[tiresString componentsSeparatedByString:@","]];
        
        NSString *chassisString = [results stringForColumn:@"chassis"];
        if (!([chassisString isEqualToString:@""] || chassisString == nil))
            [bigArray addObject:[chassisString componentsSeparatedByString:@","]];
        
        NSString *enginesString = [results stringForColumn:@"engines"];
        if (!([enginesString isEqualToString:@""] || enginesString == nil))
            [bigArray addObject:[enginesString componentsSeparatedByString:@","]];
        for (NSArray *array in bigArray) {
            for (NSString *aid in array) {
                if ([aid isEqualToString:barcode]) {
                    Driver *driver = [[Driver alloc] init];
                    [driver setDriverid:[results intForColumn:@"driverid"]];
                    [driver setDriverclass:[results stringForColumn:@"class"]];
                    [driver setName:[results stringForColumn:@"name"]];
                    [driver setKart:[results stringForColumn:@"kart"]];
                    [driver setNote:[results stringForColumn:@"note"]];
                    [driver setAMB:[results stringForColumn:@"AMB"]];
                    [driver setEventid:[results intForColumn:@"eventid"]];
                    [driver setTires:[[tiresString componentsSeparatedByString:@","] mutableCopy]];
                    [driver setEngines:[[enginesString componentsSeparatedByString:@","] mutableCopy]];
                    [driver setChassis:[[chassisString componentsSeparatedByString:@","] mutableCopy]];
                    [db close];
                    return driver;
                }
            }
        }
    }
    [db close];
    return nil;
}

- (void) storeEventFromDatabaseWithJson:(id)JSON andEvent:(Event *)event {
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open])
        return;
    [db executeUpdate:@"DELETE FROM driver WHERE eventid=?", [NSNumber numberWithInt:event.eventid]];
    for (id key in [JSON allKeys]) {
        NSString *query = [NSString stringWithFormat:@"INSERT INTO driver (name, kart, note, AMB, class, eventid) VALUES ('%@', '%@', '%@', '%@', '%@', %i)",
                           [NSString stringWithFormat:@"%@ %@", [[JSON objectForKey:key] objectForKey:@"firstname"], [[JSON objectForKey:key] objectForKey:@"lastname"]],
                           [[JSON objectForKey:key] objectForKey:@"kart"],
                           [[JSON objectForKey:key] objectForKey:@"note"],
                           [[JSON objectForKey:key] objectForKey:@"amb"],
                           [[JSON objectForKey:key] objectForKey:@"class"],
                           [event eventid]
                           ];
        [db executeUpdate:query];
    }
    [db close];
}

- (void) storeEventFromDatabaseWithJson:(id)JSON {
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open])
        return;
    [db executeUpdate:@"DELETE FROM event"];
    for (id key in [JSON allKeys]) {
        NSString *query = [NSString stringWithFormat:@"INSERT INTO event (eventid, name, location, organization, classes, start, end) VALUES (%@, '%@', '%@', '%@', '%@', '%@', '%@')",
                           [[JSON objectForKey:key] objectForKey:@"id"],
                           [[JSON objectForKey:key] objectForKey:@"name"],
                           [[JSON objectForKey:key] objectForKey:@"location"],
                           [[JSON objectForKey:key] objectForKey:@"organization"],
                           [[JSON objectForKey:key] objectForKey:@"classes"],
                           [[JSON objectForKey:key] objectForKey:@"start_date"],
                           [[JSON objectForKey:key] objectForKey:@"end_date"]
                           ];
        [db executeUpdate:query];
    }
    [db close];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEventDidChange object:nil];
}

- (void) storeDriversFromDatabaseWithJSON:(id)JSON andEventID:(int)eventID {
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open])
        return;
    FMResultSet *results = [db executeQuery:@"SELECT driverid FROM driver"];
    while ([results next]) {
        NSString *driver_id = [results stringForColumn:@"driverid"];
        if (![[JSON allKeys] containsObject:driver_id]) {
            [db executeUpdate:@"DELETE FROM driver WHERE driverid=%@", driver_id];
        }
    }
    for (id key in [JSON allKeys]) {
        if ([[[JSON objectForKey:key] objectForKey:@"synced"] boolValue]) {
            continue;
        }
        NSString *class = [[JSON objectForKey:key] objectForKey:@"class"];
        if ([class isEqualToString:@""])
            class = @"None";
        NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO driver (driverid, name, kart, note, class, tires, chassis, engines, eventid) values (%@, '%@', '%@', '%@', '%@', '%@', '%@', '%@', %i)",
                           key,
                           [[JSON objectForKey:key] objectForKey:@"name"],
                           [[JSON objectForKey:key] objectForKey:@"kart"],
                           [[JSON objectForKey:key] objectForKey:@"note"],
                           class,
                           [[JSON objectForKey:key] objectForKey:@"tires"],
                           [[JSON objectForKey:key] objectForKey:@"chassis"],
                           [[JSON objectForKey:key] objectForKey:@"engines"],
                           eventID];
//        NSString *query = [NSString stringWithFormat:@"UPDATE driver SET name='%@', kart='%@', note='%@', class='%@', tires='%@', chassis='%@', engines='%@', eventid=%i WHERE driverid=%@",
//                           [[JSON objectForKey:key] objectForKey:@"name"],
//                           [[JSON objectForKey:key] objectForKey:@"kart"],
//                           [[JSON objectForKey:key] objectForKey:@"note"],
//                           class,
//                           [[JSON objectForKey:key] objectForKey:@"tires"],
//                           [[JSON objectForKey:key] objectForKey:@"chassis"],
//                           [[JSON objectForKey:key] objectForKey:@"engines"],
//                           eventID,
//                           key
//                           ];
        [db executeUpdate:query];
    }
    [db close];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDriverDidchange object:nil];
}

- (NSArray *)getClassesFromEventID:(int)eventId {
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    if (![db open])
        return nil;
    NSString *query = [NSString stringWithFormat:@"SELECT classes FROM event WHERE eventid=%i", eventId];
    FMResultSet *results = [db executeQuery:query];
    NSMutableArray *output = [NSMutableArray array];
    while ([results next]) {
        for (NSString *class in [[results stringForColumn:@"classes"] componentsSeparatedByString:@","]) {
            [output addObject:class];
        }
    }
    [db close];
    return output;
}

@end