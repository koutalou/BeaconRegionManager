//
//  CBeacon.h
//
//  Created by koutalou on 2015/07/18.
//  Copyright (c) 2015年 KotaroKodama. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef _CBEACON_
#define _CBEACON_

#import "CBeaconReceiveManager.h"
#import "CBeaconSendManager.h"

#ifdef DEBUG
#define CBDLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define CBDLog(...)
#endif

#endif /* _CBEACON_ */
