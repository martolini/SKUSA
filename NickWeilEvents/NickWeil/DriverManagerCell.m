//
//  DriverManagerCell.m
//  NickWeil
//
//  Created by Martin Skow Røed on 08.02.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import "DriverManagerCell.h"

@implementation DriverManagerCell
@synthesize driver = _driver;

- (void) setUpWithDriver : (Driver *)driver {
    self.driver = driver;
    self.nameLabel.text = _driver.name;
    [self.tireImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%iTire.png", (driver.tires.count <= 8 ? driver.tires.count : 8)]]];
    [self.engineImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%iEngine.png", driver.engines.count]]];
    self.kartLabel.text = driver.kart;
    [self.frameImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%iFrame.png", driver.chassis.count]]];
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    [self.nameLabel setMinimumScaleFactor:0.1];
}

@end
