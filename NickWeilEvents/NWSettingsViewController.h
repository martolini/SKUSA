//
//  NWSettingsViewController.h
//  NickWeil
//
//  Created by Martin Skow Røed on 08.04.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum sectionIndexTag {
    sectionIndexIP = 0,
    sectionIndexEvents,
    sectionIndexSave
} sectionTableIndex;

@interface NWSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    NSString *ipAddress;
    int selectedEventIndex;
}

@property (strong, nonatomic) NSMutableArray *events;

@end
