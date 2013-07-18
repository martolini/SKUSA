//
//  DriverManagerCell.h
//  NickWeil
//
//  Created by Martin Skow Røed on 08.02.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//
// A simple subclass of UITableViewCell to hold a driver.

#import <UIKit/UIKit.h>
#import "Driver.h"

@interface DriverManagerCell : UITableViewCell

@property (nonatomic, strong) Driver *driver;

- (void) setUpWithDriver : (Driver *)driver;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tireImageView;
@property (weak, nonatomic) IBOutlet UIImageView *engineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *frameImageView;
@property (weak, nonatomic) IBOutlet UILabel *kartLabel;

@end
