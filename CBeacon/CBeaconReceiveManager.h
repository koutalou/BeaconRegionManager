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

@protocol CBeaconReceiveDelegate <NSObject>
@optional
- (void)didUpdatePeripheralState:(CBPeripheralManagerState)state;
- (void)didUpdateAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)startRegionMonitoring:(NSString *)identifier;
- (void)stopRegionMonitoring:(NSString *)identifier;
- (void)didRangeBeacons:(NSArray *)beacons identifier:(NSString *)identifier;
- (void)didUpdateRegionEnterOrExit:(NSString *)identifier;
@end

@interface CBeaconReceiveManager : NSObject <CBPeripheralManagerDelegate, CLLocationManagerDelegate>

@property (nonatomic) BOOL allowRanging;
@property (nonatomic, weak) id<CBeaconReceiveDelegate> delegate;

+ (CBeaconReceiveManager *)sharedManager;

- (void)monitorBeaconRegionWithUuid:(NSString *)uuid identifier:(NSString *)identifier;
- (void)monitorBeaconRegionWithUuid:(NSString *)uuid identifier:(NSString *)identifier major:(CLBeaconMajorValue)major;
- (void)monitorBeaconRegionWithUuid:(NSString *)uuid identifier:(NSString *)identifier major:(CLBeaconMajorValue)major minor:(CLBeaconMajorValue)minor;
- (void)ceaseMonitoringBeaconRegionWithIdentifer:(NSString *)identifier;

@end
