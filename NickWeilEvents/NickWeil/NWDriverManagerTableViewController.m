//
//  NWDriversTableViewController.m
//  NickWeil
//
//  Created by Martin Skow Røed on 30.01.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import "NWDriverManagerTableViewController.h"
#import "NWDriverDetailsViewController.h"
#import "Event.h"
#import "DBHandler.h"
#import "DriverManagerCell.h"
#import "NWConstants.h"
#import "NetworkHandler.h"

@implementation NWDriverManagerTableViewController
@synthesize driverArray, driverIndex;
@synthesize eventId;

- (void) initializeArrays {
    // Setting the driverArray to the already stored array in NSUserDefaults. Then we make a new array which contains the starting letters of each event.
    if (self.driverArray == nil && self.driverIndex == nil) {
        self.driverIndex = [[NSMutableArray alloc] init];
        self.driverArray = [NSMutableArray arrayWithArray:[[DBHandler sharedManager] getAllShortDriversWithEventID:self.eventId]];
    }
    else {
        [self.driverIndex removeAllObjects];
        self.driverArray = [[DBHandler sharedManager] getAllShortDriversWithEventID:self.eventId];
    }
    for (int i=0; i<self.driverArray.count; ++i) {
        [driverArray replaceObjectAtIndex:i withObject:[[DBHandler sharedManager] getWholeDriverFromShortDriver:[driverArray objectAtIndex:i]]];
    }
    
    [driverArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *first = [obj1 kart];
        NSString *second = [obj2 kart];
        return [first compare:second options:NSNumericSearch];
    }];
    // Sort the indexArray
    
    for (Driver *driver in driverArray) {
        NSString *class = [NSString stringWithFormat:@"%@", driver.driverclass];
        if (![driverIndex containsObject:class]) {
            [driverIndex addObject:class];
        }
    }
    driverIndex = [[driverIndex sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
}

- (void) initializeBarButtons {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Driver" style:UIBarButtonItemStylePlain target:self action:@selector(didPressAddDriver)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void) removeDriverFromArray : (NSIndexPath *)indexPath : (Driver *) driver {
    [driverArray removeObject:driver];
    NSString *class = [NSString stringWithFormat:@"%@",[driver driverclass]];
    if ([self.tableView numberOfRowsInSection:indexPath.section] == 1) {
        [driverIndex removeObject:class];
        [self.tableView reloadData];
    }
    else {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void) setUpWithEventID:(int)evid {
    self.eventId = evid;
    [self initializeArrays];
}

#pragma mark - UIViewController lifecycle

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NetworkHandler sharedManager] syncAllDriversWithEventID:self.eventId];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeBarButtons];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(driverDidChange:) name:kNotificationDriverDidchange object:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationDriverDidchange object:nil];
}

- (void) didPressAddDriver {
    [self performSegueWithIdentifier:kSegueIdentifierNewDriverDetails sender:self];
}

- (void) driverDidChange : (NSNotification *) note {
    [self initializeArrays];
    [self.tableView reloadData];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(DriverManagerCell *)sender {
    NWDriverDetailsViewController *dest = (NWDriverDetailsViewController *)segue.destinationViewController;
    if ([segue.identifier isEqualToString:kSegueIdentifierDriverDetails]) {
        [dest setDriver:sender.driver];
        [dest setIsNewDriver:NO];
    }
    else if ([segue.identifier isEqualToString:kSegueIdentifierNewDriverDetails]) {
        [dest setDriver:[[DBHandler sharedManager] createNewDriverWithEventId:self.eventId]];
        [dest setIsNewDriver:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [driverIndex count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Printing out the letter from our eventIndex made in initializeArrays.
    return [driverIndex objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Finds how many events starting with the letter in the section using a NSPredicate and returning it.
    NSString *class = [driverIndex objectAtIndex:section];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.driverclass like[cd] %@", class];
    return [[driverArray filteredArrayUsingPredicate:predicate] count];
}

- (DriverManagerCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    DriverManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DriverManagerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *class = [driverIndex objectAtIndex:indexPath.section];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.driverclass like[cd] %@", class];
    NSArray *driversWithFirstChar = [driverArray filteredArrayUsingPredicate:predicate];
    if ([driversWithFirstChar count] > 0) {
        [cell setUpWithDriver:[driversWithFirstChar objectAtIndex:indexPath.row]];

    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DriverManagerCell *cell = (DriverManagerCell *)[tableView cellForRowAtIndexPath:indexPath];
        [[DBHandler sharedManager] deleteDriver:[cell driver]];
        [[NetworkHandler sharedManager] deleteDriver:cell.driver];
        [self removeDriverFromArray:indexPath :[cell driver]];
    }    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:kSegueIdentifierDriverDetails sender:[tableView cellForRowAtIndexPath:indexPath]];
}

@end
