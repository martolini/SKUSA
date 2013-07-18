//
//  NetworkHandler.h
//  NickWeil
//
//  Created by Martin Skow Røed on 05.07.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Driver.h"

@interface NetworkHandler : NSObject

@property (nonatomic) BOOL connected;
@property (strong, nonatomic) NSString *ipaddress;
@property (strong, nonatomic) NSDateFormatter *formatter;


+ (NetworkHandler *)sharedManager;
- (BOOL) syncAllEvents;
- (BOOL) syncAllDriversWithEventID:(int) eventID;
- (BOOL) syncEvent:(Event *)event;
- (BOOL) syncDriver:(Driver *)driver andChanges:(NSArray *)changesMade;
- (BOOL) createNewEventFromEvent:(Event *)event;
- (BOOL) deleteEvent:(Event *)event;
- (BOOL) createNewDriverFromDriver:(Driver *)driver;
- (BOOL) deleteDriver:(Driver *)driver;

- (void) checkConnectionFromString:(NSString *)view;
- (void) pushTireRange;
- (void) showSetSettingsAlert : (NSString *)message;
- (void) getTireRange;
@end
