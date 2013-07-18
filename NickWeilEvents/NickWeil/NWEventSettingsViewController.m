//
//  NWEventSettingsViewController.m
//  NickWeil
//
//  Created by Martin Skow Røed on 17.03.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import "NWEventSettingsViewController.h"
#import "NWConstants.h"

@interface NWEventSettingsViewController ()

@end

@implementation NWEventSettingsViewController

- (void) showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void) viewDidLoad {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kUserDefaultsRanges]) {
        NSArray *ranges = [defaults arrayForKey:kUserDefaultsRanges];
        self.tireTopRange.text = [ranges objectAtIndex:iTireTopRange];
        self.tireBottomRange.text = [ranges objectAtIndex:iTireBottomRange];
        self.engineBottomRange.text = [ranges objectAtIndex:iEngineBottomRange];
        self.engineTopRange.text = [ranges objectAtIndex:iEngineTopRange];
        self.chassisBottomRange.text = [ranges objectAtIndex:iChassisBottomRange];
        self.chassisTopRange.text = [ranges objectAtIndex:iChassisTopRange];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    NSCharacterSet *numericOnly = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *theStringSet = [NSCharacterSet characterSetWithCharactersInString:textField.text];
    if (![numericOnly isSupersetOfSet:theStringSet]) {
        [self showAlertWithTitle:@"Error" andMessage:@"The range has to be numbers only. Please change it."];
        textField.text = @"";
    }
    return [textField resignFirstResponder];
}

- (BOOL) validateRangeFrom:(NSString *)lower to:(NSString *)upper {
    if (!([lower isEqualToString:@""] || [upper isEqualToString:@""])) {
        if ([upper intValue] > [lower intValue]) return YES;
        else return NO;
    }
    return YES;
}

- (IBAction)didPressSave:(id)sender {
    NSMutableArray *ranges = [NSMutableArray arrayWithCapacity:6];
    for (int i=0; i<6; ++i)
         [ranges addObject:@""];
    bool validated = YES;
    if ([self validateRangeFrom:self.tireBottomRange.text to:self.tireTopRange.text]) {
        [ranges setObject:self.tireTopRange.text atIndexedSubscript:iTireTopRange];
        [ranges setObject:self.tireBottomRange.text atIndexedSubscript:iTireBottomRange];
    }
    else validated = NO;
    if ([self validateRangeFrom:self.engineBottomRange.text to:self.engineTopRange.text]) {
        [ranges setObject:self.engineTopRange.text atIndexedSubscript:iEngineTopRange];
        [ranges setObject:self.engineBottomRange.text atIndexedSubscript:iEngineBottomRange];
    }
    else validated = NO;
    if ([self validateRangeFrom:self.chassisBottomRange.text to:self.chassisTopRange.text]) {
        [ranges setObject:self.chassisTopRange.text atIndexedSubscript:iChassisTopRange];
        [ranges setObject:self.chassisBottomRange.text atIndexedSubscript:iChassisBottomRange];
    }
    else validated = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:ranges forKey:kUserDefaultsRanges];
    [defaults synchronize];
    if (!validated) {
        [self showAlertWithTitle:@"Error" andMessage:@"There were an error trying to validate the ranges. Please make sure that everything is correct"];
    }

}
@end
