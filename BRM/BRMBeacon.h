//
//  CBeacon.h
//
//  Created by koutalou on 2015/07/18.
//  Copyright (c) 2015年 KotaroKodama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifndef _BRMBEACON_
#define _BRMBEACON_

#import "BRMRegionManager.h"
#import "BRMBeaconReceiveManager.h"
#import "BRMBeaconSendManager.h"

#ifdef DEBUG
#define BRMDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define BRMDLog(...)
#endif

#endif /* _BRMBEACON_ */
