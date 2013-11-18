//
//  NWSettingsViewController.m
//  NickWeil
//
//  Created by Martin Skow Røed on 08.04.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import "NWSettingsViewController.h"
#import "AFJSONRequestOperation.h"
#import "MBHUDView.h"
#import "DBHandler.h"
#import "NetworkHandler.h"

@interface NWSettingsViewController ()

@end

@implementation NWSettingsViewController

#pragma mark - AFNetworking

- (void) getDataFromDatabase {
    [MBHUDView dismissCurrentHUD];
    [MBHUDView hudWithBody:@"Syncing" type:MBAlertViewHUDTypeActivityIndicator hidesAfter:0 show:YES];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/datadump.php", ipAddress]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [[DBHandler sharedManager] storeEventFromDatabaseWithJson:JSON andEvent:[self.events objectAtIndex:selectedEventIndex]];
        [MBHUDView dismissCurrentHUD];
        [MBHUDView hudWithBody:@"Success" type:MBAlertViewHUDTypeCheckmark hidesAfter:1 show:YES];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [MBHUDView dismissCurrentHUD];
        MBAlertView *alert = [MBAlertView alertWithBody:[NSString stringWithFormat:@"%@", error] cancelTitle:@"Ok" cancelBlock:nil];
        [alert addToDisplayQueue];
    }];
    [op start];
}

#pragma mark - UITableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == sectionIndexEvents)
        return 1;
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    switch (indexPath.section) {
        case sectionIndexIP: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsCell"];
            UITextField *textField = (UITextField *)[cell viewWithTag:2];
            textField.placeholder = @"10.0.1.4:8888";
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField.delegate = self;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults stringForKey:@"kIPaddress"]) {
                textField.text = [defaults stringForKey:@"kIPaddress"];
            }
            break;
        }
        case sectionIndexEvents: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TireCell"];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TireCell"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if ([defaults stringForKey:@"kTireRangeLow"]) {
                UITextField *textField = (UITextField *)[cell viewWithTag:2];
                [textField setText:[defaults stringForKey:@"kTireRangeLow"]];
            }
            if ([defaults stringForKey:@"kTireRangeHigh"]) {
                UITextField *textField = (UITextField *)[cell viewWithTag:3];
                [textField setText:[defaults stringForKey:@"kTireRangeHigh"]];
            }
//            cell = [tableView dequeueReusableCellWithIdentifier:@"SaveCell"];
//            if (cell == nil)
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SaveCell"];
//            cell.textLabel.text = [[self.events objectAtIndex:indexPath.row] name];
            break;
        }
        case sectionIndexSave: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SaveCell"];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SaveCell"];
            cell.textLabel.text = @"Save & Check";
            break;
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == sectionIndexSave && indexPath.row == 0) {
        if (selectedEventIndex == -1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kIPaddressDidChange" object:nil];
            [[NetworkHandler sharedManager] checkConnectionFromString:@"settings"];
            return;
        }
        [MBHUDView hudWithBody:@"Uploading" type:MBAlertViewHUDTypeActivityIndicator hidesAfter:0 show:YES];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/test.php", ipAddress]];
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
        AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [MBHUDView dismissCurrentHUD];
            [MBHUDView hudWithBody:@"Success" type:MBAlertViewHUDTypeCheckmark hidesAfter:1.0 show:YES];
            NSUserDefaults *std = [NSUserDefaults standardUserDefaults];
            [std setObject:ipAddress forKey:@"ip"];
            [std synchronize];
            [self getDataFromDatabase];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            [MBHUDView dismissCurrentHUD];
            [MBHUDView hudWithBody:@"Error" type:MBAlertViewHUDTypeExclamationMark hidesAfter:1.0 show:YES];
            NSLog(@"%@", error);
        }];
        [op start];

    }
    else if (indexPath.section == sectionIndexEvents) {
//        if (indexPath.row != selectedEventIndex && selectedEventIndex != -1) {
//            [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedEventIndex inSection:indexPath.section]] setAccessoryType:UITableViewCellAccessoryNone];
//        }
//        selectedEventIndex = indexPath.row;
//        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UITextField

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([cell.reuseIdentifier isEqualToString:@"SettingsCell"]) {
        [userDefaults setObject:textField.text forKey:@"kIPaddress"];
        [userDefaults synchronize];
        ipAddress = textField.text;
        return [textField resignFirstResponder];
    }
    else if ([cell.reuseIdentifier isEqualToString:@"TireCell"]) {
        if (textField.tag == 2) {
            if ([textField.text intValue] != 0) {
                [userDefaults setObject:textField.text forKey:@"kTireRangeLow"];
                [userDefaults synchronize];
            }
        }
        else if (textField.tag == 3){
            if ([textField.text intValue] != 0) {
                [userDefaults setObject:textField.text forKey:@"kTireRangeHigh"];
                [userDefaults synchronize];
            }
        }
    }
    return [textField resignFirstResponder];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    //self.events = [NSArray arrayWithArray:[[DBHandler sharedManager] getAllShortEvents]];
    self.events = [NSMutableArray array];
    selectedEventIndex = -1;
    [super viewDidLoad];
}

@end
