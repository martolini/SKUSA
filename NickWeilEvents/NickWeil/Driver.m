//
//  Driver.m
//  NickWeil
//
//  Created by Martin Skow Røed on 31.01.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import "Driver.h"
#import "NWConstants.h"

@implementation Driver
@synthesize name, kart, driverclass;
@synthesize AMB, driverid, eventid;
@synthesize tires, chassis, engines;

- (BOOL) hasBarcode:(NSString *)barcode {
    for (NSString *string in [[tires arrayByAddingObjectsFromArray:engines] arrayByAddingObjectsFromArray:chassis]) {
        if ([barcode isEqualToString:string])
            return YES;
    }
    return NO;
}

+ (BOOL) validateChassis:(int)lchassis {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:kUserDefaultsRanges])
        return YES;
    NSArray *ranges = [defaults arrayForKey:kUserDefaultsRanges];
    int lower = [[ranges objectAtIndex:iChassisBottomRange] intValue];
    int upper = [[ranges objectAtIndex:iChassisTopRange] intValue];
    if (lower == 0 && upper == 0)
        return YES;
    return (lchassis > lower && lchassis < upper);
}

+ (BOOL) validateEngine:(int)lengine {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:kUserDefaultsRanges])
        return YES;
    NSArray *ranges = [defaults arrayForKey:kUserDefaultsRanges];
    int lower = [[ranges objectAtIndex:iEngineBottomRange] intValue];
    int upper = [[ranges objectAtIndex:iEngineTopRange] intValue];
    if (lower == 0 && upper == 0)
        return YES;
    return (lengine > lower && lengine < upper);
}

+ (BOOL) validateTire:(int)ltire {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:kUserDefaultsRanges])
        return YES;
    NSArray *ranges = [defaults arrayForKey:kUserDefaultsRanges];
    int lower = [[ranges objectAtIndex:iTireBottomRange] intValue];
    int upper = [[ranges objectAtIndex:iTireTopRange] intValue];
    if (lower == 0 && upper == 0)
        return YES;
    return (ltire > lower && ltire < upper);
}

+ (NWComponentRange) getRangeFor:(rangeArrayIndex) idx {
    NWComponentRange range;
    range.lower = 0;
    range.upper = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:kUserDefaultsRanges])
        return range;
    range.lower = [[defaults arrayForKey:kUserDefaultsRanges] objectAtIndex:idx];
    range.upper = [[defaults arrayForKey:kUserDefaultsRanges] objectAtIndex:idx+1];
    return range;
}

@end
