//
//  NWConstants.m
//  NickWeil
//
//  Created by Martin Skow Røed on 09.02.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import "NWConstants.h"

@implementation NWConstants

#pragma mark - Notifications

NSString *const kNotificationEventDidChange = @"EventDidChange";
NSString *const kNotificationDriverDidchange = @"DriverDidChange";

#pragma mark - Segue Identifiers

NSString *const kSegueIdentifierNewEventDetails = @"NewEventDetails";
NSString *const kSegueIdentifierEventDetails = @"EventDetails";
NSString *const kSegueIdentifierDriverManager = @"DriverManager";
NSString *const kSegueIdentifierDriverDetails = @"DriverDetails";
NSString *const kSegueIdentifierNewDriverDetails = @"NewDriverDetails";

#pragma mark - NSUserDefaults
NSString *const kUserDefaultsRanges = @"Ranges";

@end
