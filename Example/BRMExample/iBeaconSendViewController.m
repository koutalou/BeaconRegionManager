//
//  iBeaconSendViewController.m
//  BRMExample
//
//  Created by koutalou on 2015/07/26.
//  Copyright (c) 2015年 koutalou. All rights reserved.
//

#import "BRMBeacon.h"
#import "iBeaconSendViewController.h"

#define BEACON_UUID       @"2B8CA298-6420-4B28-BB93-23DCF33899B5"
#define BEACON_IDENTIFIER @"BEACON_SEND"

@interface iBeaconSendViewController ()

@end

@implementation iBeaconSendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    uuidTextField.text = BEACON_UUID;
    identifierTextField.text = BEACON_IDENTIFIER;
    
    majorTextField.text = @"1";
    minorTextField.text = @"1";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)checkValidMojorMinor
{
    NSInteger major, minor;
    major = [majorTextField.text integerValue];
    minor = [minorTextField.text integerValue];
    
    if (major <= 0 || major >= 65536) {
        sendButton.enabled = NO;
        return;
    }
    
    if (minor <= 0 || minor >= 65536) {
        sendButton.enabled = NO;
        return;
    }
    
    sendButton.enabled = YES;
}

- (IBAction)editDidEndMajorTextField:(UITextField *)sender {
    [self checkValidMojorMinor];
}

- (IBAction)editDidEndMinorTextField:(id)sender {
    [self checkValidMojorMinor];
}

- (IBAction)tapSendButton:(UIButton *)sender {
    int major, minor;
    major = (int)[majorTextField.text integerValue];
    minor = (int)[minorTextField.text integerValue];
    
    [[BRMBeaconSendManager sharedManager] startBeaconWithUUID:uuidTextField.text identifier:identifierTextField.text major:major minor:minor second:5.0];
}

@end
