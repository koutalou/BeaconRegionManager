//
//  CBeaconReceiveManager.m
//  iBeaconComm
//
//  Created by koutalou on 2015/07/18.
//  Copyright (c) 2015年 KotaroKodama. All rights reserved.
//

#import "BRMBeacon.h"
#import "BRMBeaconReceiveManager.h"

@interface BRMBeaconReceiveManager ()
@property (nonatomic, strong) BRMRegionManager *regionManager;

@end

@implementation BRMBeaconReceiveManager

+ (BRMBeaconReceiveManager *)sharedManager
{
    static BRMBeaconReceiveManager *sharedSingleton;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedSingleton = [[BRMBeaconReceiveManager alloc] init];
    });
    
    return sharedSingleton;
}

- (id)init {
    self = [super init];
    if (self) {
        _regionManager = [BRMRegionManager sharedManager];
        _regionManager.beaconReceviceDelegate = self;
    }
    return self;
}

- (void)monitorBeaconRegionWithUuid:(NSString *)uuid identifier:(NSString *)identifier
{
    BRMBeaconRegion *region = [[BRMBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] identifier:identifier];
    
    [_regionManager startBeaconRegionMonitoring:region];
}

- (void)monitorBeaconRegionWithUuid:(NSString *)uuid major:(CLBeaconMajorValue)major identifier:(NSString *)identifier
{
    BRMBeaconRegion *region = [[BRMBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] major:major identifier:identifier];

    [_regionManager startBeaconRegionMonitoring:region];
}

- (void)monitorBeaconRegionWithUuid:(NSString *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMajorValue)minor identifier:(NSString *)identifier
{
    BRMBeaconRegion *region = [[BRMBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] major:major minor:minor identifier:identifier];

    [_regionManager startBeaconRegionMonitoring:region];
}

- (void)ceaseMonitoringBeaconRegionWithIdentifer:(NSString *)identifier
{
    CLRegion *region = [_regionManager getMonitoringRegionWithIdentifier:identifier];
    if ([region isKindOfClass:[CLBeaconRegion class]] || [region isKindOfClass:[BRMBeaconRegion class]]) {
        [_regionManager stopRegionMonitoring:region];
    }
}

- (NSArray *)monitoringBeaconRegions
{
    return _regionManager.monitoringBeaconRegions;
}

#pragma mark - Override allowRanging

- (void)setAllowRanging:(BOOL)allowRanging
{
    _regionManager.allowRanging = allowRanging;
}

- (BOOL)allowRanging
{
    return _regionManager.allowRanging;
}

#pragma mark CIRegionBeaconDelegate

- (void)didUpdatePeripheralState:(CBPeripheralManagerState)state
{
    if ([_delegate respondsToSelector:@selector(didUpdatePeripheralState:)]) {
        [_delegate didUpdatePeripheralState:state];
    }
}

- (void)didUpdateAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ([_delegate respondsToSelector:@selector(didUpdateAuthorizationStatus:)]) {
        [_delegate didUpdateAuthorizationStatus:status];
    }
}

- (void)startRegionMonitoring:(NSString *)identifier
{
    if ([_delegate respondsToSelector:@selector(startRegionMonitoring:)]) {
        [_delegate startRegionMonitoring:identifier];
    }
}

- (void)stopRegionMonitoring:(NSString *)identifier
{
    if ([_delegate respondsToSelector:@selector(stopRegionMonitoring:)]) {
        [_delegate stopRegionMonitoring:identifier];
    }
}

- (void)didRangeBeacons:(NSArray *)beacons identifier:(NSString *)identifier
{
    if ([_delegate respondsToSelector:@selector(didRangeBeacons:identifier:)]) {
        [_delegate didRangeBeacons:beacons identifier:identifier];
    }
}

- (void)didUpdateRegionEnter:(NSString *)identifier
{
    if ([_delegate respondsToSelector:@selector(didUpdateRegionEnter:)]) {
        [_delegate didUpdateRegionEnter:identifier];
    }
}

- (void)didUpdateRegionExit:(NSString *)identifier
{
    if ([_delegate respondsToSelector:@selector(didUpdateRegionExit:)]) {
        [_delegate didUpdateRegionExit:identifier];
    }
}

@end
