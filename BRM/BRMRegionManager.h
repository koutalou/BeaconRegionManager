//
//  CRegionManager.h
//  iBeaconComm
//
//  Created by koutalou on 2015/07/23.
//  Copyright (c) 2015年 KotaroKodama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BRMBeaconRegion : CLBeaconRegion

@property (nonatomic) BOOL isMonitoring;
@property (nonatomic) BOOL entered;

@end

@interface BRMLocationRegion : CLCircularRegion

@property (nonatomic) BOOL isMonitoring;
@property (nonatomic) BOOL entered;

@end


@protocol IBRMRegionBeaconDelegate <NSObject>
- (void)didUpdatePeripheralState:(CBPeripheralManagerState)state;
- (void)didUpdateAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)startRegionMonitoring:(NSString *)identifier;
- (void)stopRegionMonitoring:(NSString *)identifier;
- (void)didRangeBeacons:(NSArray *)beacons identifier:(NSString *)identifier;
- (void)didUpdateRegionEnter:(NSString *)identifier;
- (void)didUpdateRegionExit:(NSString *)identifier;
@end

@protocol IBRMRegionLocationDelegate <NSObject>
- (void)didUpdatePeripheralState:(CBPeripheralManagerState)state;
- (void)didUpdateAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)startRegionMonitoring:(NSString *)identifier;
- (void)stopRegionMonitoring:(NSString *)identifier;
- (void)didUpdateRegionEnter:(NSString *)identifier;
- (void)didUpdateRegionExit:(NSString *)identifier;
@end

@interface BRMRegionManager : NSObject <CBPeripheralManagerDelegate, CLLocationManagerDelegate>

+ (BRMRegionManager *)sharedManager;

- (void)startBeaconRegionMonitoring:(BRMBeaconRegion *)beaconRegion;
- (void)startLocationRegionMonitoring:(BRMLocationRegion *)circularRegion;
- (void)stopRegionMonitoring:(CLRegion *)region;

- (CLRegion *)getRegionWithIdentifier:(NSString *)identifier;

@property (nonatomic, weak) id<IBRMRegionBeaconDelegate> beaconReceviceDelegate;
@property (nonatomic, weak) id<IBRMRegionLocationDelegate> locationReceviceDelegate;
@property (nonatomic) BOOL allowRanging;

@end
