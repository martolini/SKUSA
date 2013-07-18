//
//  NWEventDetailsTableViewController.m
//  NickWeil
//
//  Created by Martin Skow Røed on 28.01.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import "NWEventDetailsViewController.h"
#import "NWDriverManagerTableViewController.h"
#import "NWConstants.h"
#import "ActionSheetPicker.h"
#import "NetworkHandler.h"

@implementation NWEventDetailsViewController
@synthesize event;
@synthesize nameField, locationField, organizationField;
@synthesize startDateButton, endDateButton;
@synthesize isNewEvent;

- (void) updateEventDetails {
    self.event.name = self.nameField.text ? self.nameField.text : @"";
    self.event.location = self.locationField.text ? self.locationField.text : @"";
    self.event.organization = self.organizationField.text ? self.organizationField.text : @"";
    [self.event.classes removeAllObjects];
    for (NSString *class in [self.classesField.text componentsSeparatedByString:@","])
         [self.event.classes addObject:[class stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    if (isNewEvent) {
        [[NetworkHandler sharedManager] createNewEventFromEvent:self.event];
        [self setIsNewEvent:NO];
    }
    else
        [[NetworkHandler sharedManager] syncEvent:self.event];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEventDidChange object:self];
}

- (void) initializeEvent {
    self.nameField.text = [event name];
    self.locationField.text = [event location];
    self.organizationField.text = [event organization];
    self.classesField.text = [event.classes componentsJoinedByString:@","];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [self.startDateButton setTitle:[formatter stringFromDate:[event startDate]] forState:UIControlStateNormal];
    [self.endDateButton setTitle:[formatter stringFromDate:[event endDate]] forState:UIControlStateNormal];
    self.classesField.text = [self.event.classes componentsJoinedByString:@","];
    self.title = [event name];
    if (isNewEvent) {
        [self setEditing:YES animated:YES]; // If it's a new event, the edit-button should be toggled
    }
    else {
        [self setUserInteractionEnabled:NO]; // Else, set userinteraction to disabled for all
    }
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (!editing) {
        [self updateEventDetails];
    }
    [self setUserInteractionEnabled:editing];
}

- (void) setUserInteractionEnabled : (BOOL) enabled {
    [self.nameField setUserInteractionEnabled:enabled];
    [self.locationField setUserInteractionEnabled:enabled];
    [self.organizationField setUserInteractionEnabled:enabled];
    [self.startDateButton setUserInteractionEnabled:enabled];
    [self.endDateButton setUserInteractionEnabled:enabled];
    [self.classesField setUserInteractionEnabled:enabled];
}

- (IBAction)didPressSeeDrivers:(UIButton *)sender {
    [self performSegueWithIdentifier:kSegueIdentifierDriverManager sender:self];
}

- (IBAction)didPressDateButton:(UIButton *)sender {
    ActionSheetDatePicker *picker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select a date" datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] target:self action:@selector(dateWasSelected::) origin:sender];
    [picker showActionSheetPicker];
    
}

- (void) dateWasSelected : (NSDate *)selectedDate : (UIButton *) sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (sender == self.startDateButton)
        self.event.startDate = selectedDate;
    else if (sender == self.endDateButton)
        self.event.endDate = selectedDate;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [sender setTitle:[formatter stringFromDate:selectedDate] forState:UIControlStateNormal];
}

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdentifierDriverManager]) {
        NWDriverManagerTableViewController *dest = (NWDriverManagerTableViewController *)segue.destinationViewController;
        [dest setUpWithEventID:[self.event eventid]];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initializeEvent];
}

- (void) viewWillDisappear:(BOOL)animated {
    if (self.editing)
        [self setEditing:NO animated:NO];
    [super viewWillDisappear:animated];
}

#pragma mark - UITextField delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}



@end
