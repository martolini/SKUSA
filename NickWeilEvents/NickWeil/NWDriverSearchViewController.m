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
#import "NetworkHandler.h"
#import "AFJSONRequestOperation.h"

@interface NWDriverSearchViewController ()

@end

@implementation NWDriverSearchViewController
@synthesize linea;
@synthesize driver;
@synthesize tableData, scannedBarcodes;

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
    self.driver.note = @"";
    self.driver.driverclass = @"";
    [self.driver.tires removeAllObjects];
    [self.driver.chassis removeAllObjects];
    [self.driver.engines removeAllObjects];
    [self.scannedBarcodes removeAllObjects];
}

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
    if (scannedBarcodes == nil)
        self.scannedBarcodes = [NSMutableArray array];
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
    if ([driver hasBarcode:barcode]) {
        [self.scannedBarcodes addObject:barcode];
        [self.tableView reloadData];
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/search_driver.php?id=%@", [[NetworkHandler sharedManager] ipaddress], barcode]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (driver.driverid != [[JSON objectForKey:@"id"] intValue])
            [self resetDriver];
        [self.driver setName:[JSON objectForKey:@"name"]];
        [self.driver setNote:[JSON objectForKey:@"note"]];
        [self.driver setKart:[JSON objectForKey:@"kart"]];
        [self.driver setDriverclass:[JSON objectForKey:@"class"]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        if (![[JSON objectForKey:@"date"] isEqualToString:@""]) {
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *ddate = [formatter dateFromString:[JSON objectForKey:@"date"]];
            [formatter setDateFormat:@"EEEE"];
            [self.driver setAMB:[formatter stringFromDate:ddate]];
        }
        NSString *string = [JSON objectForKey:@"tires"];
        if (![string isEqualToString:@""])
            [self.driver setTires:[[string componentsSeparatedByString:@","] mutableCopy]];
        string = [JSON objectForKey:@"chassis"];
        if (![string isEqualToString:@""])
            [self.driver setChassis:[[string componentsSeparatedByString:@","] mutableCopy]];
        string = [JSON objectForKey:@"engines"];
        if (![string isEqualToString:@""])
            [self.driver setEngines:[[string componentsSeparatedByString:@","] mutableCopy]];
        [MBHUDView dismissCurrentHUD];
        [self initializeDriver];
        [self.scannedBarcodes addObject:barcode];
        [self.tableView reloadData];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [MBHUDView dismissCurrentHUD];
        [MBHUDView hudWithBody:@"No driver found" type:MBAlertViewHUDTypeExclamationMark hidesAfter:1.5 show:YES];
    }];
    [MBHUDView hudWithBody:@"Searching" type:MBAlertViewHUDTypeActivityIndicator hidesAfter:10 show:YES];
    [op start];
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
    if ([scannedBarcodes containsObject:cellText])
        [cell.textLabel setTextColor:[UIColor greenColor]];
    else
        [cell.textLabel setTextColor:[UIColor blackColor]];
    return cell;
}


@end
