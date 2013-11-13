//
//  NetworkHandler.m
//  NickWeil
//
//  Created by Martin Skow Røed on 05.07.13.
//  Copyright (c) 2013 Martin Skow Røed. All rights reserved.
//

#import "NetworkHandler.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "DBHandler.h"
#import "MBHUDView.h"
#import "NWDriverDetailsViewController.h"

@implementation NetworkHandler
@synthesize ipaddress, connected, formatter;


+ (NetworkHandler *)sharedManager {
    static NetworkHandler *instance = nil;
    if (instance == nil) {
        instance = [[NetworkHandler alloc] init];
        instance.connected = NO;
        instance.ipaddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"kIPaddress"];
        instance.formatter = [[NSDateFormatter alloc] init];
        [instance.formatter setDateFormat:@"yyyy-MM-dd"];
        [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(ipDidChange:) name:@"kIPaddressDidChange" object:nil];
    }
    return instance;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kIPaddressDidChange" object:nil];
}

- (void) ipDidChange:(NSNotification *)note {
    [self setIpaddress:[[NSUserDefaults standardUserDefaults] stringForKey:@"kIPaddress"]];
    [self setConnected:NO];
}

- (BOOL) syncAllEvents {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/get_events.php", ipaddress]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
        if ([JSON count]) {
            if ([userDefaults objectForKey:@"eventJSON"]) {
                if (!([(NSDictionary *)[userDefaults objectForKey:@"eventJSON"] isEqualToDictionary:(NSDictionary *)JSON])) {
                    [[DBHandler sharedManager] storeEventFromDatabaseWithJson:JSON];
                    [userDefaults setObject:JSON forKey:@"eventJSON"];
                }
                else {
                    [[DBHandler sharedManager] storeEventFromDatabaseWithJson:JSON];
                }
            }
            else {
                [[DBHandler sharedManager] storeEventFromDatabaseWithJson:JSON];
                [userDefaults setObject:JSON forKey:@"eventJSON"];
                [userDefaults synchronize];
            }
        }
        else {
            [[DBHandler sharedManager] storeEventFromDatabaseWithJson:[NSDictionary dictionary]];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self setConnected:NO];
        [self checkConnectionFromString:@""];
        NSLog(@"error = %@", error);
    }];
    [op start];
    return YES;
}

- (BOOL) syncAllDriversWithEventID:(int) eventID {
    [MBHUDView hudWithBody:@"Synchronizing" type:MBAlertViewHUDTypeActivityIndicator hidesAfter:10 show:YES];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/get_drivers.php?id=%i", ipaddress, eventID]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [[NetworkHandler sharedManager] getTireRange];
        if ([JSON count]) {
            if ([userDefaults objectForKey:@"driverJSON"]) {
                if (!([(NSDictionary *)[userDefaults objectForKey:@"driverJSON"] isEqualToDictionary:(NSDictionary *)JSON])) {
                    [[DBHandler sharedManager] storeDriversFromDatabaseWithJSON:JSON andEventID:eventID];
                    [userDefaults setObject:JSON forKey:@"driverJSON"];
                }
                else {
                    //[[DBHandler sharedManager] storeDriversFromDatabaseWithJSON:JSON andEventID:eventID];
                }
            }
            else {
                [[DBHandler sharedManager] storeDriversFromDatabaseWithJSON:JSON andEventID:eventID];
                [userDefaults setObject:JSON forKey:@"driverJSON"];
                [userDefaults synchronize];
            }
        }
        [MBHUDView dismissCurrentHUDAfterDelay:0.2];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self setConnected:NO];
        [self checkConnectionFromString:@""];
        NSLog(@"error = %@", error);
        [MBHUDView dismissCurrentHUDAfterDelay:0.2];
    }];
    [op start];
    return YES;

}

- (BOOL) syncEvent:(Event *)event {
    NSString *stringUrl = [NSString stringWithFormat:@"http://%@/sync_event.php?id=%i&name=%@&loc=%@&org=%@&classes=%@&start_date=%@&end_date=%@", ipaddress, event.eventid, event.name, event.location, event.organization, [event.classes componentsJoinedByString:@","], [formatter stringFromDate:event.startDate], [formatter stringFromDate:event.endDate]];
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (CFStringRef)stringUrl,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@" ",
                                                                                                    kCFStringEncodingUTF8 ));

    NSURL *url = [NSURL URLWithString:encodedString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setConnected:NO];
        [self checkConnectionFromString:@""];
        NSLog(@"error = %@", error);
    }];
    [op start];
    return YES;
}

- (BOOL) createNewEventFromEvent:(Event *)event{
    NSString *strurl = [NSString stringWithFormat:@"http://%@/create_event.php?name=%@&loc=%@&org=%@&classes=%@&start_date=%@&end_date=%@", ipaddress, event.name, event.location, event.organization, [event.classes componentsJoinedByString:@","], [formatter stringFromDate:event.startDate], [formatter stringFromDate:event.endDate]];
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)strurl,
                                                                                  NULL,
                                                                                  (CFStringRef)@" ",
                                                                                  kCFStringEncodingUTF8 ));
    NSURL *url = [NSURL URLWithString:encodedString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setConnected:NO];
        [self checkConnectionFromString:@""];
        NSLog(@"error = %@", error);
    }];
    [operation start];
    return YES;
}

- (BOOL) deleteEvent:(Event *)event {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/delete_event.php?id=%i", ipaddress, event.eventid]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setConnected:NO];
        [self checkConnectionFromString:@""];
        NSLog(@"error = %@", error);
    }];
    [operation start];
    return YES;
}

- (BOOL) deleteDriver:(Driver *)driver {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/delete_driver.php?id=%i", ipaddress, driver.driverid]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setConnected:NO];
        [self checkConnectionFromString:@""];
        NSLog(@"error = %@", error);
    }];
    [operation start];
    return YES;
}

- (BOOL) syncDriver:(Driver *)driver andChanges:(NSArray *)changesMade {
    NSString *tires = [[changesMade objectAtIndex:NWTableOrderTires] boolValue] ? [driver.tires componentsJoinedByString:@","] : @"-1";
    NSString *chassis = [[changesMade objectAtIndex:NWTableOrderChassis] boolValue] ? [driver.chassis componentsJoinedByString:@","] : @"-1";
    NSString *engines = [[changesMade objectAtIndex:NWTableOrderEngines] boolValue] ? [driver.engines componentsJoinedByString:@","] : @"-1";
    
    NSString *stringUrl = [NSString stringWithFormat:@"http://%@/sync_driver.php?id=%i&name=%@&kart=%@&note=%@&class=%@&tire=%@&chassis=%@&engine=%@",
                           ipaddress,
                           driver.driverid,
                           driver.name,
                           driver.kart,
                           driver.note,
                           driver.driverclass,
                           tires,
                           chassis,
                           engines];
    
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (CFStringRef)stringUrl,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@" ",
                                                                                                    kCFStringEncodingUTF8 ));
    
    NSURL *url = [NSURL URLWithString:encodedString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op start];
    [op setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setConnected:NO];
        [self checkConnectionFromString:@""];
        NSLog(@"error = %@", error);
    }];
    return YES;
}

- (BOOL) createNewDriverFromDriver:(Driver *)driver{
    NSString *strurl = [NSString stringWithFormat:@"http://%@/create_driver.php?name=%@&kart=%@&note=%@&event_id=%i&class=%@", ipaddress, driver.name, driver.kart, driver.note, driver.eventid, driver.driverclass];
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (CFStringRef)strurl,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@" ",
                                                                                                    kCFStringEncodingUTF8 ));
    NSURL *url = [NSURL URLWithString:encodedString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self setConnected:NO];
        [self checkConnectionFromString:@""];
        NSLog(@"error = %@", error);
    }];
    [operation start];
    return YES;
}

- (void) checkConnectionFromString:(NSString *)view {
    if (!connected) {
        [MBHUDView hudWithBody:@"Checking connection.." type:MBAlertViewHUDTypeActivityIndicator hidesAfter:10 show:YES];
        if (self.ipaddress) {
            NSString *url = [NSString stringWithFormat:@"http://%@/test.php", ipaddress];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            [req setHTTPMethod:@"GET"];
            [req setTimeoutInterval:5.0f];
            AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                if (JSON) {
                    if ([[JSON objectForKey:@"mysql_error"] boolValue]) {
                        [self showSetSettingsAlert:@"There is a problem with the MySQL connection. Please contact someone who knows what he's doing."];
                        connected = NO;
                    }
                    else  {
                        [MBHUDView dismissCurrentHUD];
                        [MBHUDView hudWithBody:@"Connection established" type:MBAlertViewHUDTypeCheckmark hidesAfter:1 show:YES];
                        connected = YES;
                        if ([view isEqualToString:@"splash"])
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"kDidConnect" object:nil];
                    }
                    [[NetworkHandler sharedManager] pushTireRange];
                }
                else connected = NO;
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                [self showSetSettingsAlert:@"Could not connect to the server. Make sure you've set the right IPadress on the settingspage"];
                connected = NO;
                NSLog(@"%@", error);
            }];
            [op start];
        }
        else {
            [self showSetSettingsAlert:@"You have not yet set a IPaddress. Please do that on the settingspage"];
            connected = NO;
        }
    }
}

- (void) showSetSettingsAlert : (NSString *)message {
    MBAlertView *alert = [MBAlertView alertWithBody:message cancelTitle:@"Ok" cancelBlock:nil];
    [MBHUDView dismissCurrentHUD];
    [alert addToDisplayQueue];
}

- (void) pushTireRange {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *low = [defaults objectForKey:@"kTireRangeLow"];
    NSString *high = [defaults objectForKey:@"kTireRangeHigh"];
    if ([low isEqualToString:@""] || [high isEqualToString:@""])
        return;
    NSString *strurl = [NSString stringWithFormat:@"http://%@/push_tirerange.php?lower=%@&higher=%@", ipaddress, low, high];
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (CFStringRef)strurl,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@" ",
                                                                                                    kCFStringEncodingUTF8 ));
    NSURL *url = [NSURL URLWithString:encodedString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error = %@", error);
    }];
    [operation start];

}

- (void) getTireRange {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/get_tirerange.php", ipaddress]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        for (id key in [JSON allKeys]) {
            NSString *raw = [JSON objectForKey:key];
            NSArray *arr = [raw componentsSeparatedByString:@"-"];
            [userDefaults setObject:@"kTireRangeLow" forKey:[arr objectAtIndex:0]];
            [userDefaults setObject:@"kTireRangeHigh" forKey:[arr objectAtIndex:1]];
            [userDefaults synchronize];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error = %@", error);
    }];
    [op start];
}



@end
