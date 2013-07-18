//
//  NWEventSettingsViewController.h
//  NickWeil
//
//  Created by Martin Skow Røed on 17.03.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NWEventSettingsViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tireBottomRange;
@property (weak, nonatomic) IBOutlet UITextField *tireTopRange;
@property (weak, nonatomic) IBOutlet UITextField *engineBottomRange;
@property (weak, nonatomic) IBOutlet UITextField *engineTopRange;
@property (weak, nonatomic) IBOutlet UITextField *chassisBottomRange;
@property (weak, nonatomic) IBOutlet UITextField *chassisTopRange;

- (void) showAlertWithTitle:(NSString *)title andMessage : (NSString *)message;
- (IBAction)didPressSave:(id)sender;

@end
