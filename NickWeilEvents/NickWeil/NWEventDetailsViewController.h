//
//  NWEventDetailsTableViewController.h
//  NickWeil
//
//  Created by Martin Skow Røed on 28.01.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//
// Used to display information about one single event. There is an editbutton to edit details about the event. It's a subclas of UIViewController because it always has the same number of properties. There's a UITableView as the rootview of the controller, to get the Grouped Table View background, so it could be consistent throught the application.

#import <UIKit/UIKit.h>
#import "Event.h"
#import "DBHandler.h"

@interface NWEventDetailsViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) Event *event;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UITextField *organizationField;
@property (weak, nonatomic) IBOutlet UITextField *classesField;
@property (weak, nonatomic) IBOutlet UIButton *startDateButton;
@property (weak, nonatomic) IBOutlet UIButton *endDateButton;
@property (nonatomic) BOOL isNewEvent; // Property sent from NWEventManager if they're pressing Add Event

- (void) updateEventDetails; // Updating the local event details, in the database, and posting notification to NWEventManager to refresh its data
- (void) initializeEvent; // Initializing the event sent from NWEventManager
- (void) setEditing:(BOOL)editing animated:(BOOL)animated; // Overriding the default to server our purpose.
- (void) setUserInteractionEnabled : (BOOL) enabled; // Toggling the userinteraction on all properties.
- (IBAction)didPressSeeDrivers:(UIButton *)sender;
- (BOOL) textFieldShouldReturn:(UITextField *)textField;
- (IBAction)didPressDateButton:(UIButton *)sender;

@end
