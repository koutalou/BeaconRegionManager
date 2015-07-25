//
//  CBeaconReceiveManager.h
//  iBeaconComm
//
//  Created by koutalou on 2015/07/18.
//  Copyright (c) 2015年 KotaroKodama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BRMBeaconReceiveDelegate <NSObject>
@optional
- (void)didUpdatePeripheralState:(CBPeripheralManagerState)state;
- (void)didUpdateAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)startRegionMonitoring:(NSString *)identifier;
- (void)stopRegionMonitoring:(NSString *)identifier;
- (void)didRangeBeacons:(NSArray *)beacons identifier:(NSString *)identifier;
- (void)didUpdateRegionEnter:(NSString *)identifier;
- (void)didUpdateRegionExit:(NSString *)identifier;
@end

@interface BRMBeaconReceiveManager : NSObject <IBRMRegionBeaconDelegate>

@property (nonatomic) BOOL allowRanging;
@property (nonatomic, weak) id<BRMBeaconReceiveDelegate> delegate;

+ (BRMBeaconReceiveManager *)sharedManager;

- (void)monitorBeaconRegionWithUuid:(NSString *)uuid identifier:(NSString *)identifier;
- (void)monitorBeaconRegionWithUuid:(NSString *)uuid major:(CLBeaconMajorValue)major identifier:(NSString *)identifier;
- (void)monitorBeaconRegionWithUuid:(NSString *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMajorValue)minor identifier:(NSString *)identifier;
- (void)ceaseMonitoringBeaconRegionWithIdentifer:(NSString *)identifier;

@end
