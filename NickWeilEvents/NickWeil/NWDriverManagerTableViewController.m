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
#import "MBHUDView.h"
#import "NetworkHandler.h"

@implementation NWDriverManagerTableViewController
@synthesize driverArray, driverIndex, filteredDriversArray, filteredDriversIndex;
@synthesize eventId;
@synthesize driverSearchBar;

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
    if (filteredDriversArray == nil)
        filteredDriversArray = [NSMutableArray arrayWithCapacity:driverArray.count];
    if (filteredDriversIndex == nil)
        filteredDriversIndex = [NSMutableArray array];
    
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
    [MBHUDView hudWithBody:@"Creating new driver..." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:0 show:YES];
    [[NetworkHandler sharedManager] createNewDriver:self.eventId withSuccess:^(int driverid) {
        [MBHUDView dismissCurrentHUD];
        Driver *driver = [[DBHandler sharedManager] createNewDriverWithDriverId:driverid andEventId:self.eventId];
        [self performSegueWithIdentifier:kSegueIdentifierNewDriverDetails sender:driver];
    } andError:^{
        [MBHUDView dismissCurrentHUD];
        [MBHUDView hudWithBody:@"Something went wrong.." type:MBAlertViewHUDTypeExclamationMark hidesAfter:1.5 show:YES];
        }];
}

- (void) driverDidChange : (NSNotification *) note {
    [self initializeArrays];
    [self.searchDisplayController.searchResultsTableView reloadData];
    [self.tableView reloadData];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NWDriverDetailsViewController *dest = (NWDriverDetailsViewController *)segue.destinationViewController;
    if ([segue.identifier isEqualToString:kSegueIdentifierDriverDetails]) {
        DriverManagerCell *cell = ((DriverManagerCell *) sender);
        [dest setDriver:cell.driver];
        [dest setIsNewDriver:NO];
    }
    else if ([segue.identifier isEqualToString:kSegueIdentifierNewDriverDetails]) {
        Driver *driver = (Driver *)sender;
        [dest setDriver:driver];
        [dest setIsNewDriver:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [filteredDriversIndex count];
    return [driverIndex count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Printing out the letter from our eventIndex made in initializeArrays.
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [filteredDriversIndex objectAtIndex:section];
    return [driverIndex objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Finds how many events starting with the letter in the section using a NSPredicate and returning it.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSString *class = [filteredDriversIndex objectAtIndex:section];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.driverclass like[cd] %@", class];
        return [[filteredDriversArray filteredArrayUsingPredicate:predicate] count];
    }
    NSString *class = [driverIndex objectAtIndex:section];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.driverclass like[cd] %@", class];
    return [[driverArray filteredArrayUsingPredicate:predicate] count];
}

- (DriverManagerCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    DriverManagerCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[DriverManagerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSString *class = [filteredDriversIndex objectAtIndex:indexPath.section];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.driverclass like[cd] %@", class];
        NSArray *driversWithFirstChar = [filteredDriversArray filteredArrayUsingPredicate:predicate];
        if ([driversWithFirstChar count] > 0) {
             [cell setUpWithDriver:[driversWithFirstChar objectAtIndex:indexPath.row]];
        }
    }
    else {
        NSString *class = [driverIndex objectAtIndex:indexPath.section];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.driverclass like[cd] %@", class];
        NSArray *driversWithFirstChar = [driverArray filteredArrayUsingPredicate:predicate];
        if ([driversWithFirstChar count] > 0) {
            [cell setUpWithDriver:[driversWithFirstChar objectAtIndex:indexPath.row]];
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return NO;
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

#pragma mark - Content Filtering

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredDriversArray removeAllObjects];
    [self.filteredDriversIndex removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.name contains[c] %@) OR (SELF.kart contains[c] %@) OR (SELF.driverclass contains[c] %@)",searchText, searchText, searchText];
    filteredDriversArray = [NSMutableArray arrayWithArray:[driverArray filteredArrayUsingPredicate:predicate]];
    for (Driver *driver in filteredDriversArray) {
        if (![filteredDriversIndex containsObject:driver.driverclass])
            [filteredDriversIndex addObject:driver.driverclass];
    }
    filteredDriversIndex = [[filteredDriversIndex sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] mutableCopy];
}

#pragma mark - UISearchDisplayController Delegate
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
