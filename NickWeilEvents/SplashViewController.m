//
//  SplashViewController.m
//  NickWeil
//
//  Created by Nicholas Weil on 3/27/13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import "SplashViewController.h"
#import "MBAlertView.h"
#import "MBHUDView.h"
#import "AFJSONRequestOperation.h"
#import "NetworkHandler.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.tabBarController.delegate = self;
}


- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
    
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPressLetsGo:) name:@"kDidConnect" object:nil];
	// Do any additional setup after loading the view.
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kDidConnect" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressLetsGo:(id)sender {
    if ([[NetworkHandler sharedManager] connected]) {
        [self performSegueWithIdentifier:@"splashToEventManager" sender:self];
    }
    else {
        [[NetworkHandler sharedManager] checkConnectionFromString:@"splash"];
    }
}
@end
