//
//  CBeaconReceiveManager.m
//  iBeaconComm
//
//  Created by koutalou on 2015/07/18.
//  Copyright (c) 2015年 KotaroKodama. All rights reserved.
//

#import "CBeacon.h"
#import "CBeaconReceiveManager.h"

@interface CBeaconRegion : CLBeaconRegion

@property (nonatomic) BOOL isMonitoring;
@property (nonatomic) BOOL entered;

@end

@implementation CBeaconRegion

@end

@interface CBeaconReceiveManager ()
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *regions;

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
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        self.allowRanging = YES;
        _regions = [@[] mutableCopy];
        
        float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (iOSVersion >= 8.0) {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    return self;
}

- (void)monitorBeaconRegionWithUuid:(NSString *)uuid identifier:(NSString *)identifier
{
    CBeaconRegion *region = [[CBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] identifier:identifier];
    
    [self startRegionMonitoring:region];
}

- (void)monitorBeaconRegionWithUuid:(NSString *)uuid identifier:(NSString *)identifier major:(CLBeaconMajorValue)major
{
    CBeaconRegion *region = [[CBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] major:major identifier:identifier];

    [self startRegionMonitoring:region];
}

- (void)monitorBeaconRegionWithUuid:(NSString *)uuid identifier:(NSString *)identifier major:(CLBeaconMajorValue)major minor:(CLBeaconMajorValue)minor
{
    CBeaconRegion *region = [[CBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] major:major minor:minor identifier:identifier];

    [self startRegionMonitoring:region];
}

- (void)ceaseMonitoringBeaconRegionWithIdentifer:(NSString *)identifier
{
    for (CLRegion *monitorRegion in _locationManager.monitoredRegions) {
        if (![monitorRegion isKindOfClass:[CLBeaconRegion class]] ) {
            continue;
        }
        if ([identifier isEqualToString:monitorRegion.identifier]) {
            [self stopRegionMonitoring:(CLBeaconRegion *)monitorRegion];
        }
    }
    
    for (CLRegion *monitorRegion in _regions) {
        if (![monitorRegion isKindOfClass:[CLBeaconRegion class]] ) {
            continue;
        }
        if ([identifier isEqualToString:monitorRegion.identifier]) {
            [self stopRegionMonitoring:(CLBeaconRegion *)monitorRegion];
        }
    }
}

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

#pragma mark - CBPeripheralManagerDelegate

- (NSString *)peripheralStateString:(CBPeripheralManagerState)state
{
    switch (state) {
        case CBPeripheralManagerStatePoweredOn:
            return @"On";
        case CBPeripheralManagerStatePoweredOff:
            return @"Off";
        case CBPeripheralManagerStateResetting:
            return @"Resetting";
        case CBPeripheralManagerStateUnauthorized:
            return @"Unauthorized";
        case CBPeripheralManagerStateUnknown:
            return @"Unknown";
        case CBPeripheralManagerStateUnsupported:
            return @"Unsupported";
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    CBDLog(@"Peripheral state %@", [self peripheralStateString:peripheral.state]);
    
    [self checkMonitoringRegion];
    
    if ([_delegate respondsToSelector:@selector(didUpdatePeripheralState:)]) {
        [_delegate didUpdatePeripheralState:peripheral.state];
    }
}

#pragma mark CLLocationManagerDelegate - Authorization
- (NSString *)locationAuthorizationStatusString:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            return @"Not determined";
        case kCLAuthorizationStatusRestricted:
            return @"Restricted";
        case kCLAuthorizationStatusDenied:
            return @"Denied";
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
        case kCLAuthorizationStatusAuthorizedAlways:
            return @"Authorized always";
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return @"Authorized when in use";
#else
        case kCLAuthorizationStatusAuthorized:
            return @"Authorized";
#endif
    }
    return @"";
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    CBDLog(@"Status %@", [self locationAuthorizationStatusString:status]);
    
    [self checkMonitoringRegion];
    
    if ([_delegate respondsToSelector:@selector(didUpdateAuthorizationStatus:)]) {
        [_delegate didUpdateAuthorizationStatus:status];
    }
}

#pragma mark CLLocationManagerDelegate - Region

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    CBDLog(@"Identifier %@", region.identifier);
    
    [self.locationManager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [self enterRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[CLBeaconRegion class]]) {
        [self exitRegion:(CLBeaconRegion *)region];
    }
}

- (NSString *)regionStateString:(CLRegionState)state
{
    switch (state) {
        case CLRegionStateInside:
            return @"Inside";
        case CLRegionStateOutside:
            return @"Outside";
        default: CLRegionStateUnknown:
            return @"Unknown";
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    CBDLog(@"Region %@, Identifier: %@", [self regionStateString:state], region.identifier);
    
    if ([self isMonitoringBeaconRegion:region]) {
        switch (state) {
            case CLRegionStateInside:
                [self enterRegion:(CLBeaconRegion *)region];
                break;
            case CLRegionStateOutside:
            case CLRegionStateUnknown:
                [self exitRegion:(CLBeaconRegion *)region];
                break;
            default:
                break;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    CBDLog(@"Identifier %@, Error %@", region.identifier, error);
    
    if (![self isMonitoringBeaconRegion:region]) {
        return;
    }
    
    [self stopRegionMonitoring:(CLBeaconRegion *)region];
}

#pragma mark - CLLocationManagerDelegate - Ranging

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CBDLog(@"Identifier %@", region.identifier);
    
    if (![self isMonitoringBeaconRegion:region]) {
        return;
    }
    
    
    NSString *identifier = region.identifier;
    
    if ([_delegate respondsToSelector:@selector(didRangeBeacons:identifier:)]) {
        [_delegate didRangeBeacons:beacons identifier:identifier];
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    CBDLog(@"Identifier %@, Error %@", region.identifier, error);
    
    if (![self isMonitoringBeaconRegion:region]) {
        return;
    }
}

@end
