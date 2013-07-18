//
//  NWEventManagerTableViewController.m
//  NickWeil
//
//  Created by Martin Skow Røed on 28.01.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import "NWEventManagerTableViewController.h"
#import "DBHandler.h"
#import "NWEventDetailsViewController.h"
#import "EventManagerCell.h"
#import "NWConstants.h"
#import "NetworkHandler.h"

@implementation NWEventManagerTableViewController
@synthesize eventIndex, eventArray;

- (void) initializeArrays {
    // Setting the eventArray to the already stored array in NSUserDefaults. Then we make a new array which contains the starting letters of each event.
    if (self.eventArray == nil && self.eventIndex == nil) {
        self.eventIndex = [[NSMutableArray alloc] init];
        self.eventArray = [NSMutableArray arrayWithArray:[[DBHandler sharedManager] getAllShortEvents]];
    }
    else {
        [self.eventIndex removeAllObjects];
        [self.eventArray removeAllObjects];
        self.eventArray = [[DBHandler sharedManager] getAllShortEvents];
    }
    // Sort the indexArray
    
    for (Event *event in eventArray) {
        NSString *uniChar = [NSString stringWithFormat:@"%c", [[event name] characterAtIndex:0]];
        if (![eventIndex containsObject:uniChar])
            [eventIndex addObject:uniChar];
    }
}

- (void) initializeBarButtons {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Add event" style:UIBarButtonItemStylePlain target:self action:@selector(didPressAddEvent)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void) didPressAddEvent {
    [self performSegueWithIdentifier:kSegueIdentifierNewEventDetails sender:self];
}

- (void) eventDidChange : (NSNotification *) note {
    [self initializeArrays]; // Fetch from the db again.
    [self.tableView reloadData];
}

- (void) removeEventFromArray : (NSIndexPath *) indexPath : (Event *) ev {
    [eventArray removeObject:ev];
    NSString *firstChar = [NSString stringWithFormat:@"%c", [ev.name characterAtIndex:0]];
    if ([self.tableView numberOfRowsInSection:indexPath.section] == 1) {
        [eventIndex removeObject:firstChar];
        [self.tableView reloadData];
    }
    else {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeArrays];
    [self initializeBarButtons];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventDidChange:) name:kNotificationEventDidChange object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    [[NetworkHandler sharedManager] syncAllEvents];
    [super viewDidAppear:animated];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationEventDidChange object:nil];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NWEventDetailsViewController *dest = (NWEventDetailsViewController *)segue.destinationViewController;
    if ([segue.identifier isEqualToString:kSegueIdentifierEventDetails]) {
        EventManagerCell *cell = (EventManagerCell*)sender;
        [dest setEvent:[[DBHandler sharedManager] getWholeEventFromShortEvent:[cell event]]];
        [dest setIsNewEvent:NO];
    }
    else if ([segue.identifier isEqualToString:kSegueIdentifierNewEventDetails]) {
        [dest setEvent:[[DBHandler sharedManager] createNewEvent]];
        [dest setIsNewEvent:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Number of sections is the count of the tableArray
    return [eventIndex count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Finds how many events starting with the letter in the section using a NSPredicate and returning it.
    NSString *firstChar = [eventIndex objectAtIndex:section];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name beginswith[c] %@", firstChar];
    return [[eventArray filteredArrayUsingPredicate:predicate] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Printing out the letter from our eventIndex made in initializeArrays.
    return [eventIndex objectAtIndex:section];
}

- (EventManagerCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    EventManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[EventManagerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *firstChar = [eventIndex objectAtIndex:indexPath.section];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name beginswith[c] %@", firstChar];
    NSArray *eventsWithfirstChar = [eventArray filteredArrayUsingPredicate:predicate];
    if ([eventsWithfirstChar count] > 0) {
        [cell setUpWithEvent:[eventsWithfirstChar objectAtIndex:indexPath.row]];
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
        EventManagerCell *cell = (EventManagerCell*)[tableView cellForRowAtIndexPath:indexPath];
        [[NetworkHandler sharedManager] deleteEvent:[cell event]];
        [[DBHandler sharedManager] deleteEvent:cell.event];
        [self removeEventFromArray:indexPath :cell.event];
    }   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:kSegueIdentifierEventDetails sender:(EventManagerCell *)[tableView cellForRowAtIndexPath:indexPath]];
}

@end
