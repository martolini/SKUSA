//
//  NWDriverSearchViewController.h
//  NickWeil
//
//  Created by Martin Skow Røed on 27.03.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Driver.h"
#import "DTDevices.h"

typedef enum {
    NWTableOrderTires = 0,
    NWTableOrderChassis = 1,
    NWTableOrderEngines = 2
} NWDriverDetailsTableOrder;

@interface NWDriverSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DTDeviceDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *kartField;
@property (weak, nonatomic) IBOutlet UITextField *ambField;
@property (weak, nonatomic) IBOutlet UITextField *classField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *tableData, *scannedBarcodes;
@property (strong, nonatomic) Driver *driver;
@property (weak, nonatomic) DTDevices *linea;

-(void)barcodeData:(NSString *)barcode type:(int)type;
-(void)connectionState:(int)state;

@end
