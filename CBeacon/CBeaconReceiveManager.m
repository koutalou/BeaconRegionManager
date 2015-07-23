//
//  CBeaconReceiveManager.m
//  iBeaconComm
//
//  Created by koutalou on 2015/07/18.
//  Copyright (c) 2015年 KotaroKodama. All rights reserved.
//

#import "CBeacon.h"
#import "CBeaconReceiveManager.h"

@interface CBeaconReceiveManager ()
@property (nonatomic, strong) CRegionManager *regionManager;

@end

@implementation CBeaconReceiveManager

+ (CBeaconReceiveManager *)sharedManager
{
    static CBeaconReceiveManager *sharedSingleton;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedSingleton = [[CBeaconReceiveManager alloc] init];
    });
    
    return sharedSingleton;
}

- (id)init {
    self = [super init];
    if (self) {
        _regionManager = [CRegionManager sharedManager];
        _regionManager.beaconReceviceDelegate = self;
    }
    return self;
}

- (void)monitorBeaconRegionWithUuid:(NSString *)uuid identifier:(NSString *)identifier
{
    CBeaconRegion *region = [[CBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] identifier:identifier];
    
    [_regionManager startBeaconRegionMonitoring:region];
}

- (void)monitorBeaconRegionWithUuid:(NSString *)uuid major:(CLBeaconMajorValue)major identifier:(NSString *)identifier
{
    CBeaconRegion *region = [[CBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] major:major identifier:identifier];

    [_regionManager startBeaconRegionMonitoring:region];
}

- (void)monitorBeaconRegionWithUuid:(NSString *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMajorValue)minor identifier:(NSString *)identifier
{
    CBeaconRegion *region = [[CBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] major:major minor:minor identifier:identifier];

    [_regionManager startBeaconRegionMonitoring:region];
}

- (void)ceaseMonitoringBeaconRegionWithIdentifer:(NSString *)identifier
{
    CLRegion *region = [_regionManager getRegionWithIdentifier:identifier];
    if ([region isKindOfClass:[CLBeaconRegion class]] || [region isKindOfClass:[CBeaconRegion class]]) {
        [_regionManager stopRegionMonitoring:region];
    }
}

/*
- (BOOL)isEqualBeaonRegion:(CLBeaconRegion *)beaconRegion targetRegion:(CLRegion *)region
{
    if (![region isKindOfClass:[CLBeaconRegion class]] ) {
        return NO;
    }
    
    CLBeaconRegion *targetBeaconRegion = (CLBeaconRegion *)region;
    if (![targetBeaconRegion.proximityUUID.UUIDString isEqualToString:beaconRegion.proximityUUID.UUIDString]) {
        return NO;
    }
    if (![targetBeaconRegion.identifier isEqualToString:beaconRegion.identifier]) {
        return NO;
    }
    if (!targetBeaconRegion.major) {
        if (targetBeaconRegion.major != beaconRegion.major) {
            return NO;
        }
    }
    else {
        if (![targetBeaconRegion.major isEqualToNumber:beaconRegion.major]) {
            return NO;
        }
    }
    if (!targetBeaconRegion.minor) {
        if (targetBeaconRegion.minor != beaconRegion.minor) {
            return NO;
        }
    }
    else {
        if (![targetBeaconRegion.minor isEqualToNumber:beaconRegion.minor]) {
            return NO;
        }
    }
    
    return YES;
}

- (CLBeaconRegion *)getMonitoringBeaconRegion:(CLRegion *)region
{
    if (![region isKindOfClass:[CLBeaconRegion class]]) {
        return nil;
    }

    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    
    for (CLRegion *monitorRegion in _locationManager.monitoredRegions) {
        if ([self isEqualBeaonRegion:beaconRegion targetRegion:monitorRegion]) {
            return (CLBeaconRegion *)monitorRegion;
        }
    }
    
    for (CLRegion *monitorRegion in _regions) {
        if ([self isEqualBeaonRegion:beaconRegion targetRegion:monitorRegion]) {
            return (CLBeaconRegion *)monitorRegion;
        }
    }
    
    return nil;
}

- (BOOL)isMonitoringBeaconRegion:(CLRegion *)region
{
    CLBeaconRegion *beaconRegion = [self getMonitoringBeaconRegion:region];
    if (beaconRegion) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isMonitoringCapable
{
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        return NO;
    }
    if (_peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        return NO;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        return NO;
    }
    return YES;
}

- (void)startRegionMonitoring:(CBeaconRegion *)beaconRegion
{
    CLBeaconRegion *sameRegion = (CBeaconRegion *)[self getMonitoringBeaconRegion:beaconRegion];
    if (!sameRegion) {
        [_regions addObject:beaconRegion];
    }

    if (![sameRegion isKindOfClass:[CBeaconRegion class]]) {
        return;
    }

    CBeaconRegion *sameCBeaconRegion = (CBeaconRegion *)sameRegion;
    if (sameCBeaconRegion.isMonitoring) {
        return;
    }
    
    [_locationManager startMonitoringForRegion:beaconRegion];
    beaconRegion.isMonitoring = YES;
    
    if ([_delegate respondsToSelector:@selector(startRegionMonitoring:)]) {
        [_delegate startRegionMonitoring:beaconRegion.identifier];
    }
}

- (void)stopRegionMonitoring:(CLBeaconRegion *)beaconRegion
{
    [_locationManager stopMonitoringForRegion:beaconRegion];
    if ([beaconRegion isKindOfClass:[CBeaconRegion class]]) {
        CBeaconRegion *cBeaconRegion = (CBeaconRegion *)beaconRegion;
        cBeaconRegion.isMonitoring = NO;
    }
    
    if ([_delegate respondsToSelector:@selector(stopRegionMonitoring:)]) {
        [_delegate stopRegionMonitoring:beaconRegion.identifier];
    }
}

- (void)checkMonitoringRegion
{
    if ([self isMonitoringCapable]) {
        for (CBeaconRegion *beaconRegion in _regions) {
            if (!beaconRegion.isMonitoring) {
                [self startRegionMonitoring:beaconRegion];
            }
        }
    }
}

- (void)enterRegion:(CLBeaconRegion *)region
{
    CBDLog(@"Identifier %@", region.identifier);
    
    if (![self isMonitoringBeaconRegion:region]) {
        return;
    }
    
    if (_allowRanging) {
        [_locationManager startRangingBeaconsInRegion:region];
    }
    
    if ([_delegate respondsToSelector:@selector(didUpdateRegionEnterOrExit:)]) {
        [_delegate didUpdateRegionEnterOrExit:region.identifier];
    }
}

- (void)exitRegion:(CLBeaconRegion *)region
{
    CBDLog(@"Identifier %@", region.identifier);
    
    if (![self isMonitoringBeaconRegion:region]) {
        return;
    }
    
    [_locationManager stopRangingBeaconsInRegion:region];
    
    if ([_delegate respondsToSelector:@selector(didUpdateRegionEnterOrExit:)]) {
        [_delegate didUpdateRegionEnterOrExit:region.identifier];
    }
}
*/

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
