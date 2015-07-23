//
//  CLocationReceiveManager.h
//  iBeaconComm
//
//  Created by koutalou on 2015/07/23.
//  Copyright (c) 2015年 KotaroKodama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol CLocationReceiveDelegate <NSObject>
@optional
- (void)didUpdatePeripheralState:(CBPeripheralManagerState)state;
- (void)didUpdateAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)startRegionMonitoring:(NSString *)identifier;
- (void)stopRegionMonitoring:(NSString *)identifier;
- (void)didUpdateRegionEnter:(NSString *)identifier;
- (void)didUpdateRegionExit:(NSString *)identifier;
@end

@interface CLocationReceiveManager : NSObject <CIRegionLocationDelegate>

+ (CLocationReceiveManager *)sharedManager;
- (void)monitorLocationRegionWithLatitude:(double)latitude longitude:(double)longitude distance:(NSInteger)distance identifier:(NSString *)identifier;

@property (nonatomic, weak) id<CLocationReceiveDelegate> delegate;

@end
