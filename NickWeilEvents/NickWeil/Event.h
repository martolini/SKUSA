//
//  Event.h
//  NickWeil
//
//  Created by Martin Skow Røed on 31.01.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//
// An event object to store the properties listed.

#import <Foundation/Foundation.h>

@interface Event : NSObject // 
@property (nonatomic) int eventid;
@property (nonatomic, strong) NSString *name, *organization, *location;
@property (nonatomic, strong) NSMutableArray *classes;
@property (nonatomic, strong) NSDate *startDate, *endDate;

@end
