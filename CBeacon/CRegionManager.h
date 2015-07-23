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

@interface CBeaconRegion : CLBeaconRegion

@property (nonatomic) BOOL isMonitoring;
@property (nonatomic) BOOL entered;

@end

@interface CLocationRegion : CLCircularRegion

@property (nonatomic) BOOL isMonitoring;
@property (nonatomic) BOOL entered;

@end


@protocol CIRegionBeaconDelegate <NSObject>
- (void)didUpdatePeripheralState:(CBPeripheralManagerState)state;
- (void)didUpdateAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)startRegionMonitoring:(NSString *)identifier;
- (void)stopRegionMonitoring:(NSString *)identifier;
- (void)didRangeBeacons:(NSArray *)beacons identifier:(NSString *)identifier;
- (void)didUpdateRegionEnter:(NSString *)identifier;
- (void)didUpdateRegionExit:(NSString *)identifier;
@end

@protocol CIRegionLocationDelegate <NSObject>
- (void)didUpdatePeripheralState:(CBPeripheralManagerState)state;
- (void)didUpdateAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)startRegionMonitoring:(NSString *)identifier;
- (void)stopRegionMonitoring:(NSString *)identifier;
- (void)didUpdateRegionEnter:(NSString *)identifier;
- (void)didUpdateRegionExit:(NSString *)identifier;
@end

@interface CRegionManager : NSObject <CBPeripheralManagerDelegate, CLLocationManagerDelegate>

+ (CRegionManager *)sharedManager;

- (void)startBeaconRegionMonitoring:(CBeaconRegion *)beaconRegion;
- (void)startLocationRegionMonitoring:(CLocationRegion *)circularRegion;
- (void)stopRegionMonitoring:(CLRegion *)region;

- (CLRegion *)getRegionWithIdentifier:(NSString *)identifier;

@property (nonatomic, weak) id<CIRegionBeaconDelegate> beaconReceviceDelegate;
@property (nonatomic, weak) id<CIRegionLocationDelegate> locationReceviceDelegate;
@property (nonatomic) BOOL allowRanging;

@end
