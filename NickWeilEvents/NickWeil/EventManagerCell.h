//
//  EventManagerCell.h
//  NickWeil
//
//  Created by Martin Skow Røed on 01.02.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//
// A simple UITableViewCell subclass used to store an event.

#import <UIKit/UIKit.h>
#import "Event.h"

@interface EventManagerCell : UITableViewCell

@property (strong, nonatomic) Event *event;

- (void) setUpWithEvent : (Event *) event;


@end
