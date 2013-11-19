//
//  NWDriverDetailsViewController.m
//  NickWeil
//
//  Created by Martin Skow Røed on 09.02.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import "NWDriverDetailsViewController.h"
#import "DBHandler.h"
#import "NWConstants.h"
#import "MBHUDView.h"
#import "NetworkHandler.h"
#import "ActionSheetStringPicker.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation NWDriverDetailsViewController
@synthesize tableData, changesMade;
@synthesize driver;
@synthesize isNewDriver;
@synthesize linea;
@synthesize alert;

- (void) initializeDriver {
    self.nameField.text = driver.name;
    self.classField.text = driver.driverclass;
    self.ambField.text = driver.AMB;
    self.kartField.text = driver.kart;
    self.notesField.text = driver.note;
    if (driver.tires == nil)
        self.driver.tires = [NSMutableArray array];
    if (driver.chassis == nil)
        self.driver.chassis = [NSMutableArray array];
    if (driver.engines == nil)
        self.driver.engines = [NSMutableArray array];
    self.classes = [NSArray arrayWithArray:[[DBHandler sharedManager] getClassesFromEventID:driver.eventid]];
    changesMade = [NSMutableArray arrayWithCapacity:3];
    for (int i=0; i<3; ++i)
        [changesMade setObject:[NSNumber numberWithBool:NO] atIndexedSubscript:i];
    self.title = [driver name];
    if ([self isNewDriver])
        [self setEditing:YES animated:YES];
    else [self setUserInteractionEnabled:NO];
}

- (void) initializeTableView {
    tableData = [NSMutableArray arrayWithCapacity:3];
    [tableData setObject:driver.tires atIndexedSubscript:NWTableOrderTires];
    [tableData setObject:driver.chassis atIndexedSubscript:NWTableOrderChassis];
    [tableData setObject:driver.engines atIndexedSubscript:NWTableOrderEngines];
    [self reloadTableAndScroller:NO:nil];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self reloadTableAndScroller:NO:nil];
    if (!editing) {
        [self updateDriverDetails]; // When the user clicks on done.
        [linea disconnect];
        [linea removeDelegate:self];
        [UIView animateWithDuration:1 animations:^{
            self.segmentScan.alpha = 0.0;
            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y-45, self.tableView.frame.size.width, self.tableView.frame.size.height);
        }];
    }
    else {
        [linea addDelegate:self];
        [linea connect];
        [linea barcodeSetScanMode:BARCODE_TYPE_DEFAULT error:nil];
        [linea barcodeStartScan:nil];

        [UIView animateWithDuration:1 animations:^{
            self.segmentScan.alpha = 1.0;
            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y+45, self.tableView.frame.size.width, self.tableView.frame.size.height);
        }];
    }
    [self setUserInteractionEnabled:editing];
}

- (void) setUserInteractionEnabled : (BOOL) enabled {
    [self.nameField setUserInteractionEnabled:enabled];
    [self.classField setUserInteractionEnabled:enabled];
    [self.ambField setUserInteractionEnabled:enabled];
    [self.kartField setUserInteractionEnabled:enabled];
    [self.notesField setUserInteractionEnabled:enabled];
    [self reloadTableAndScroller:NO:nil];
}

- (void) updateDriverDetails {
    self.driver.name = self.nameField.text ? self.nameField.text : @"";
    self.driver.AMB = self.ambField.text ? self.ambField.text : @"";
    self.driver.kart = self.kartField.text ? self.kartField.text : @"";
    self.driver.driverclass = self.classField.text ? self.classField.text : @"";
    self.driver.note = self.notesField.text ? self.notesField.text : @"";
    self.driver.tires = [tableData objectAtIndex:NWTableOrderTires];
    self.driver.chassis = [tableData objectAtIndex:NWTableOrderChassis];
    self.driver.engines = [tableData objectAtIndex:NWTableOrderEngines];
    self.title = driver.name;
    if (isNewDriver) {
        [[NetworkHandler sharedManager] createNewDriverFromDriver:self.driver];
        [self setIsNewDriver:NO];
    }
    else {
        [[NetworkHandler sharedManager] syncDriver:self.driver andChanges:changesMade];
    }
    [[DBHandler sharedManager] updateDriver:driver];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDriverDidchange object:nil];
}

- (void) updateDriverClass:(NSNumber *)selectedIndex element:(id)element {
    self.driver.driverclass = [self.classes objectAtIndex:[selectedIndex intValue]];
    self.classField.text = [self.classes objectAtIndex:[selectedIndex intValue]];
}

- (void) updateDriverDetailsWithBarcode {
    self.driver.tires = [tableData objectAtIndex:NWTableOrderTires];
    self.driver.chassis = [tableData objectAtIndex:NWTableOrderChassis];
    self.driver.engines = [tableData objectAtIndex:NWTableOrderEngines];
    [[DBHandler sharedManager] updateDriver:driver];
}


#pragma mark - UIViewController lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
    self.segmentScan.alpha = 0;
    alert = [[UIAlertView alloc] init];
    alert.delegate = self;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.linea = [DTDevices sharedDevice];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initializeDriver];
    [self initializeTableView];
}

- (void) viewWillDisappear:(BOOL)animated {
    if (self.editing)
        [self setEditing:NO animated:NO];
    [super viewWillDisappear:animated];
}

#pragma mark - IBAction

- (IBAction)didPressClassField:(id)sender {
    [ActionSheetStringPicker showPickerWithTitle:@"Select class" rows:self.classes initialSelection:0 target:self successAction:@selector(updateDriverClass:element:) cancelAction:nil origin:sender];
}

#pragma mark - LINEA

-(void)connectionState:(int)state {
    switch (state) {
        case CONN_CONNECTED: {
            [MBHUDView dismissCurrentHUD];
            [MBHUDView hudWithBody:@"Scanner connected"type:MBAlertViewHUDTypeCheckmark hidesAfter:1.5 show:YES];
        }
            break;
        case CONN_CONNECTING: {
            MBAlertView *tempalert = [MBAlertView alertWithBody:@"Please press scanner side button" cancelTitle:@"Cancel" cancelBlock:^{
                [self setEditing:NO animated:NO];
            }];
            [tempalert addToDisplayQueue];
        }
            break;
        case CONN_DISCONNECTED: {
            [MBHUDView hudWithBody:@"Scanner disconnected" type:MBAlertViewHUDTypeExclamationMark hidesAfter:1.5 show:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIAlertView delegate

- (void) showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *tempalert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [tempalert show];
}

- (void)alertView:(UIAlertView *)lalert clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        UITextField *textField = [lalert textFieldAtIndex:0];
        NSString *text = textField.text;
        if(text == nil || [text isEqualToString:@""]) {
            return;
        } else {
            switch (lalert.tag) {
                case NWTableOrderTires: {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    int lower = [[defaults stringForKey:@"kTireRangeLow"] intValue];
                    int higher = [[defaults stringForKey:@"kTireRangeHigh"] intValue];
                    if (lower > 0 && higher > 0) {
                        if ([text intValue] < lower || [text intValue] > higher) {
                            [self showAlertWithTitle:@"Error" andMessage:@"Tire value out of range!"];
                            [self playSound];
                            return;
                        }
                    }
                    if ([[DBHandler sharedManager] hasDuplicate:text  inEvent:driver.eventid andType:NWTableOrderTires]) {
                        [self showAlertWithTitle:@"Error" andMessage:@"Tire Number already in use."];
                        return;
                    }
                    break;
                }
                case NWTableOrderEngines:
                    if ([[DBHandler sharedManager] hasDuplicate:text inEvent:driver.eventid andType:NWTableOrderEngines]) {
                        [self showAlertWithTitle:@"Error" andMessage:@"Engine Seal already in use. Could not validate the engine."];
                        return;
                    }
                    break;
                case NWTableOrderChassis:
                    if([[DBHandler sharedManager] hasDuplicate:text inEvent:driver.eventid andType:NWTableOrderChassis]) {
                        [self showAlertWithTitle:@"Error" andMessage:@"Chassis Seal already in use."];
                        return;
                    }
                    break;
                default:
                    break;
            }
            [[tableData objectAtIndex:lalert.tag] addObject:text];
            [changesMade setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:lalert.tag];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[tableData objectAtIndex:lalert.tag] count]-1 inSection:lalert.tag];
            [self reloadTableAndScroller:YES:indexPath];
            [self updateDriverDetailsWithBarcode];
        }
    }
}

#pragma mark - UITableView datasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isEditing])
        return [[tableData objectAtIndex:section] count]+1;
    if ([[tableData objectAtIndex:section] count] == 0)
        return 1;
    return [[tableData objectAtIndex:section] count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [tableData count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case NWTableOrderTires:
            return @"Tires";
        case NWTableOrderChassis:
            return @"Chassis";
        case NWTableOrderEngines:
            return @"Engines";
    }
    return @"";
}

#pragma mark - UITableView delegate


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    NSString *cellText;
    
    if ([self isEditing] && indexPath.row == [[tableData objectAtIndex:indexPath.section] count]) {
        switch (indexPath.section) {
            case NWTableOrderTires:
                cellText = @"Add a new tire";
                break;
            case NWTableOrderChassis:
                cellText = @"Add a new chassis";
                break;
            case NWTableOrderEngines:
                cellText = @"Add a new engine";
                break;
        }
    }
    else if ([[tableData objectAtIndex:indexPath.section] count] == 0)
        cellText = @"None";
    else cellText = [[tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = cellText;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [[tableData objectAtIndex:indexPath.section] count])
        return NO;
    return [self isEditing];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from tableData
        [[tableData objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
        [changesMade setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:indexPath.section];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [[tableData objectAtIndex:indexPath.section] count] && [self isEditing]) {
        if (alert.numberOfButtons == 0) {
            [alert addButtonWithTitle:@"Cancel"];
            [alert addButtonWithTitle:@"Done"];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *textField = [alert textFieldAtIndex:0];
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.placeholder = @"unit id";
        }
        UITextField *textfield = [alert textFieldAtIndex:0];
        [textfield setText:@""];
        alert.tag = indexPath.section;
        [alert show];
    }
    //Deselecting the cell when clicked on.
    [(UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
}

- (void) reloadTableAndScroller : (BOOL) animated : (NSIndexPath *)indexPath {
    if (animated)
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    else
        [self.tableView reloadData];
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame
                                      .origin.y, 320, self.tableView.contentSize.height);
    [self.scroller setContentSize:CGSizeMake(320, self.tableView.frame.origin.y+self.tableView.contentSize.height+100)];
}



-(void)barcodeData:(NSString *)barcode type:(int)type {
    if (!self.isEditing)
        return;
    NSString *componentType;
    if ([alert isVisible]) {
        UITextField *textField = [alert textFieldAtIndex:0];
        [textField setText:barcode];
        return;
    }
    for (rangeArrayIndex rangeidx = 0; rangeidx<iNumberOfIndexes; rangeidx+= 2) {
        NWComponentRange range = [Driver getRangeFor:rangeidx];
        int iBarcode = [barcode intValue];
        if (iBarcode >= range.lower && iBarcode <= range.upper) {
            switch (rangeidx) {
                case iEngineBottomRange:
                case iEngineTopRange:
                    componentType = @"engine";
                    break;
                case iTireBottomRange:
                case iTireTopRange:
                    componentType = @"tire";
                    break;
                case iChassisBottomRange:
                case iChassisTopRange:
                    componentType = @"chassis";
                    break;
                default:
                    break;
            }
        }
    }
    NSString *alertString;
    if (componentType)
        alertString = [NSString stringWithFormat:@"It looks like a %@", componentType];
    else alertString = @"";
    UIAlertView *dummyAlert = [[UIAlertView alloc] initWithTitle:@"dummy" message:@"dummy" delegate:self cancelButtonTitle:@"dummy" otherButtonTitles:@"dummy", nil];
    dummyAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *dummyTextField = [dummyAlert textFieldAtIndex:0];
    [dummyTextField setText:barcode];
    dummyAlert.tag = self.segmentScan.selectedSegmentIndex;
    [self alertView:dummyAlert clickedButtonAtIndex:1];
    return;
//    MBAlertView *mbalert = [MBAlertView alertWithBody:[NSString stringWithFormat:@"Barcode scanned: %@\%@\nWhere do you want to put it?", barcode, alertString] cancelTitle:nil cancelBlock:nil];
//    [mbalert addButtonWithText:@"Tire" type:MBAlertViewItemTypeDefault block:^{
//        dummyAlert.tag = NWTableOrderTires;
//        [self alertView:dummyAlert clickedButtonAtIndex:1];
//    }];
//    [mbalert addButtonWithText:@"Engine" type:MBAlertViewItemTypeDefault block:^{
//        dummyAlert.tag = NWTableOrderEngines;
//        [self alertView:dummyAlert clickedButtonAtIndex:1];
//    }];
//    [mbalert addButtonWithText:@"Chassis" type:MBAlertViewItemTypeDefault block:^{
//        dummyAlert.tag = NWTableOrderChassis;
//        [self alertView:dummyAlert clickedButtonAtIndex:1];
//    }];
//    [mbalert addToDisplayQueue];
}

#pragma mark - UITextField delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.classField)
        return NO;
    return YES;
}

#pragma mark - UISegment

- (IBAction) didPressSegmentField : (UISegmentedControl *) seg {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:seg.selectedSegmentIndex];
    CGRect rectOfCellInTableView = [self.tableView rectForRowAtIndexPath:indexPath];
    CGRect rectOfCellInSuperview = [self.tableView convertRect:rectOfCellInTableView toView:[self.tableView superview]];
    [self.scroller setContentOffset:CGPointMake(0, rectOfCellInSuperview.origin.y-45) animated:YES];
}


#pragma mark - Play sound
- (void) playSound {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"alert" ofType:@"wav"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    AudioServicesPlaySystemSound(soundID);
}

@end