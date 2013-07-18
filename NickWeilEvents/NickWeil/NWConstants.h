//
//  NWConstants.h
//  NickWeil
//
//  Created by Martin Skow Røed on 09.02.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    iTireBottomRange,
    iTireTopRange,
    iEngineBottomRange,
    iEngineTopRange,
    iChassisBottomRange,
    iChassisTopRange,
    iNumberOfIndexes
} rangeArrayIndex;

@interface NWConstants : NSObject

#pragma mark - Notifications
extern NSString *const kNotificationEventDidChange;
extern NSString *const kNotificationDriverDidchange;

#pragma mark - Segues
extern NSString *const kSegueIdentifierNewEventDetails;
extern NSString *const kSegueIdentifierEventDetails;
extern NSString *const kSegueIdentifierDriverManager;
extern NSString *const kSegueIdentifierDriverDetails;
extern NSString *const kSegueIdentifierNewDriverDetails;

#pragma mark - NSUSerDefaults
extern NSString *const kUserDefaultsRanges;

@end
