//
//  NWDriverDetailsViewController.h
//  NickWeil
//
//  Created by Martin Skow Røed on 09.02.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//
// Displays all the data of the driver. This consists of multiple UITextFields to display the single properties, and an UITableView to display the tires, chasssises and engines in three different sections.

#import <UIKit/UIKit.h>
#import "Driver.h"
#import "DTDevices.h"
#import "TPKeyboardAvoidingScrollView.h"

typedef enum {
    NWTableOrderTires = 0,
    NWTableOrderChassis = 1,
    NWTableOrderEngines = 2
} NWDriverDetailsTableOrder;

@interface NWDriverDetailsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, DTDeviceDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *kartField;
@property (weak, nonatomic) IBOutlet UITextField *ambField;
@property (weak, nonatomic) IBOutlet UITextField *classField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *notesField;
@property (strong, nonatomic) NSMutableArray *tableData, *changesMade;
@property (strong, nonatomic) NSArray *classes;
@property (strong, nonatomic) Driver *driver;
@property (strong, nonatomic) UIAlertView *alert;
@property (nonatomic) BOOL isNewDriver;
@property (weak, nonatomic) DTDevices *linea;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scroller;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentScan;

- (void) initializeDriver; // Initializing the driver with the driver sent from NWDriverManager
- (void) initializeTableView;
- (void) setEditing:(BOOL)editing animated:(BOOL)animated; // Overriding the default to server our purpose.
- (void) setUserInteractionEnabled : (BOOL) enabled; // Toggling the user interaction on all properties
- (void) updateDriverDetails; // Called after the didPressEitDriver is pressed back to Done. Updates the local driver, the driver in the datbase, as well as posting a notification to NWDriverManager to notify that the driver has changed.
- (IBAction)didPressClassField:(id)sender;

-(void)barcodeData:(NSString *)barcode type:(int)type;
-(void)connectionState:(int)state;
- (IBAction) didPressSegmentField : (UISegmentedControl *) seg;



@end
