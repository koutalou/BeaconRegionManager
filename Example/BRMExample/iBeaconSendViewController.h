//
//  iBeaconSendViewController.h
//  BRMExample
//
//  Created by koutalou on 2015/07/26.
//  Copyright (c) 2015年 koutalou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iBeaconSendViewController : UIViewController {
    
    __weak IBOutlet UITextField *uuidTextField;
    __weak IBOutlet UITextField *identifierTextField;
    __weak IBOutlet UITextField *majorTextField;
    __weak IBOutlet UITextField *minorTextField;
    __weak IBOutlet UIButton *sendButton;
}

@end
