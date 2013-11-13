//
//  Driver.h
//  NickWeil
//
//  Created by Martin Skow Røed on 31.01.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//
// A driver object to store all the drivers information.
// The arrays are stored as a string in the database, in the format [123124,1238723,123871236,1231237] and deserialized with the [NSString componentsSeparatedByString:] to get back into an array. A mutable copy is needed of the array. If the string is empty, it returns an empty array as well.

#import <Foundation/Foundation.h>
#import "NWConstants.h"

typedef struct componentRange {
    int lower;
    int upper;
} NWComponentRange;

@interface Driver : NSObject

@property (nonatomic, strong) NSString *name, *kart, *driverclass, *AMB;
@property (nonatomic) int driverid, eventid;
@property (nonatomic, strong) NSMutableArray *tires, *chassis, *engines;

+ (BOOL) validateTire:(int)ltire;
+ (BOOL) validateEngine:(int)lengine;
+ (BOOL) validateChassis:(int)lchassis;

+ (NWComponentRange) getRangeFor:(rangeArrayIndex) idx;

@end
