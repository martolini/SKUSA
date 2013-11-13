//
//  NWDriverSearchViewController.m
//  NickWeil
//
//  Created by Martin Skow Røed on 27.03.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import "NWDriverSearchViewController.h"
#import "MBHUDView.h"
#import "DBHandler.h"

@interface NWDriverSearchViewController ()

@end

@implementation NWDriverSearchViewController
@synthesize linea;
@synthesize driver;
@synthesize tableData;

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.linea = [DTDevices sharedDevice];
    [self setDriver:[[Driver alloc] init]];
    [self initializeTableView];
    if([linea.deviceName rangeOfString:@"LINEAPro5"].location!=NSNotFound) //checks for LP5
    {
        [linea setAutoOffWhenIdle:15000 whenDisconnected:15000 error:nil]; //sets USB auto off at 1hr
    }
	// Do any additional setup after loading the view.
}


- (void) viewDidAppear:(BOOL)animated {
    [self.linea addDelegate:self];
    [linea connect];
    [linea barcodeSetScanMode:BARCODE_TYPE_DEFAULT error:nil];
    [linea barcodeStartScan:nil];
    [self initializeDriver];
}

- (void) viewDidDisappear:(BOOL)animated {
    [linea disconnect];
    [linea removeDelegate:self];
    [self resetDriver];
}

- (void) dealloc {
    self.driver = nil;
    self.tableData = nil;
}

- (void) resetDriver {
    self.driver.name = @"";
    self.driver.kart = @"";
    self.driver.AMB = @"";
    self.driver.driverclass = @"";
    [self.driver.tires removeAllObjects];
    [self.driver.chassis removeAllObjects];
    [self.driver.engines removeAllObjects];
}

- (void) initializeDriver {
    self.nameField.text = driver.name;
    self.classField.text = driver.driverclass;
    self.ambField.text = driver.AMB;
    self.kartField.text = driver.kart;
    if (driver.tires == nil)
        self.driver.tires = [NSMutableArray array];
    if (driver.chassis == nil)
        self.driver.chassis = [NSMutableArray array];
    if (driver.engines == nil)
        self.driver.engines = [NSMutableArray array];
    [tableData setObject:driver.tires atIndexedSubscript:NWTableOrderTires];
    [tableData setObject:driver.chassis atIndexedSubscript:NWTableOrderChassis];
    [tableData setObject:driver.engines atIndexedSubscript:NWTableOrderEngines];
    [self.tableView reloadData];
}

- (void) initializeTableView {
    if (tableData == nil)
        tableData = [NSMutableArray arrayWithCapacity:3];
}

#pragma mark - Linea

-(void)connectionState:(int)state {
    switch (state) {
        case CONN_CONNECTED: {
            [MBHUDView dismissCurrentHUD];
            [MBHUDView hudWithBody:@"Scanner connected"type:MBAlertViewHUDTypeCheckmark hidesAfter:1.5 show:YES];
        }
            break;
        case CONN_CONNECTING: {
            MBAlertView *tempalert = [MBAlertView alertWithBody:@"Please press scanner side button" cancelTitle:@"Cancel" cancelBlock:nil];
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

-(void)barcodeData:(NSString *)barcode type:(int)type {
    Driver *ldriver = [[DBHandler sharedManager] getDriverFromBarcode:barcode];
    if (!ldriver) {
        [MBHUDView hudWithBody:@"No driver found" type:MBAlertViewHUDTypeDefault hidesAfter:1.5 show:YES];
        return;
    }
    [self setDriver:ldriver];
    [self initializeDriver];
    
    [self.tableView reloadData];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    NSString *cellText;
    if ([[tableData objectAtIndex:indexPath.section] count] == 0)
        cellText = @"None";
    else cellText = [[tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = cellText;
    return cell;
}


@end
