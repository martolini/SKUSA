//
//  AppDelegate.h
//  NickWeil
//
//  Created by Martin Skow Røed on 28.01.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *databaseName, *databasePath;

@end
