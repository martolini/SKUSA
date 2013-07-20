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
    self.linea = [Linea sharedDevice];
    [self setDriver:[[Driver alloc] init]];
    [self initializeTableView];
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
    [self.scannedBarcodes removeAllObjects];
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
            MBAlertView *tempalert = [MBAlertView alertWithBody:@"Connecting to scanner" cancelTitle:@"Cancel" cancelBlock:nil];
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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/search_driver.php?id=%@", [[NetworkHandler sharedManager] ipaddress], barcode]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self.driver setName:[JSON objectForKey:@"name"]];
        [self.driver setKart:[JSON objectForKey:@"kart"]];
        [self.driver setDriverclass:[JSON objectForKey:@"class"]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *ddate = [formatter dateFromString:[JSON objectForKey:@"date"]];
        [formatter setDateFormat:@"EEEE"];
        [self.driver setAMB:[formatter stringFromDate:ddate]];
        [self.driver setTires:[JSON objectForKey:@"tires"]];
        [self.driver setEngines:[JSON objectForKey:@"engines"]];
        [self.driver setChassis:[JSON objectForKey:@"chassis"]];
        [MBHUDView dismissCurrentHUD];
        [self.scannedBarcodes addObject:barcode];
        [self initializeDriver];
        [self.tableView reloadData];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [MBHUDView dismissCurrentHUD];
        [MBHUDView hudWithBody:@"No driver found" type:MBAlertViewHUDTypeExclamationMark hidesAfter:1.5 show:YES];
    }];
    [MBHUDView hudWithBody:@"Searching" type:MBAlertViewHUDTypeActivityIndicator hidesAfter:10 show:YES];
    [op start];
//    Driver *ldriver = [[DBHandler sharedManager] getDriverFromBarcode:barcode];
//    if (!ldriver) {
//        [MBHUDView hudWithBody:@"No driver found" type:MBAlertViewHUDTypeDefault hidesAfter:1.5 show:YES];
//        return;
//    }
    
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
    return cell;
}


@end
