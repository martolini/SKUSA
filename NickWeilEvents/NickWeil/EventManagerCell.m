//
//  EventManagerCell.m
//  NickWeil
//
//  Created by Martin Skow Røed on 01.02.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import "EventManagerCell.h"

@implementation EventManagerCell
@synthesize event = _event;

- (void) setUpWithEvent:(Event *)event {
    self.event = event;
    self.textLabel.text = _event.name;
}


@end
