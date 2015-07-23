//
//  CRegionManager.m
//  iBeaconComm
//
//  Created by koutalou on 2015/07/23.
//  Copyright (c) 2015年 KotaroKodama. All rights reserved.
//

#import "CBeacon.h"
#import "CRegionManager.h"

@implementation CBeaconRegion
@end
@implementation CLocationRegion
@end

@interface CRegionManager ()
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *regions;

@end

@implementation CRegionManager

+ (CRegionManager *)sharedManager
{
    static CRegionManager *sharedSingleton;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedSingleton = [[CRegionManager alloc] init];
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

#pragma mark - Public function

- (void)startBeaconRegionMonitoring:(CBeaconRegion *)beaconRegion
{
    CLBeaconRegion *sameRegion = (CBeaconRegion *)[self getMonitoringBeaconRegion:beaconRegion];
    if (!sameRegion) {
        [_regions addObject:beaconRegion];
    }
    
    if (sameRegion && ![sameRegion isKindOfClass:[CBeaconRegion class]]) {
        return;
    }
    
    CBeaconRegion *sameCBeaconRegion = (CBeaconRegion *)sameRegion;
    if (sameCBeaconRegion.isMonitoring) {
        return;
    }
    
    if (![self isMonitoringCapable]) {
        return;
    }
    
    [_locationManager startMonitoringForRegion:beaconRegion];
    beaconRegion.isMonitoring = YES;
    
    if ([self.beaconReceviceDelegate respondsToSelector:@selector(startRegionMonitoring:)]) {
        [self.beaconReceviceDelegate startRegionMonitoring:beaconRegion.identifier];
    }
}

- (void)startLocationRegionMonitoring:(CLocationRegion *)circularRegion
{
    CLCircularRegion *sameRegion = (CLCircularRegion *)[self getMonitoringLocationRegion:circularRegion];
    if (!sameRegion) {
        [_regions addObject:circularRegion];
    }
    
    if (sameRegion && ![sameRegion isKindOfClass:[CBeaconRegion class]]) {
        return;
    }
    
    CBeaconRegion *sameCBeaconRegion = (CBeaconRegion *)sameRegion;
    if (sameCBeaconRegion.isMonitoring) {
        return;
    }
    
    if (![self isMonitoringCapable]) {
        return;
    }

    [_locationManager startMonitoringForRegion:circularRegion];
    circularRegion.isMonitoring = YES;
    
    if ([self.locationReceviceDelegate respondsToSelector:@selector(startRegionMonitoring:)]) {
        [self.locationReceviceDelegate startRegionMonitoring:circularRegion.identifier];
    }
}

- (void)stopRegionMonitoring:(CLRegion *)region
{
    if ([self isMonitoringBeaconRegion:region]) {
        [_locationManager stopMonitoringForRegion:region];
        if ([self.beaconReceviceDelegate respondsToSelector:@selector(stopRegionMonitoring:)]) {
            [self.beaconReceviceDelegate stopRegionMonitoring:region.identifier];
        }
    }
    if ([self isMonitoringLocationRegion:region]) {
        [_locationManager stopMonitoringForRegion:region];
        if ([self.locationReceviceDelegate respondsToSelector:@selector(stopRegionMonitoring:)]) {
            [self.locationReceviceDelegate stopRegionMonitoring:region.identifier];
        }
    }
}

#pragma mark - Public function for ReceiveManager

- (BOOL)isEqualBeaonRegion:(CLBeaconRegion *)beaconRegion targetRegion:(CLRegion *)region
{
    if (![region isKindOfClass:[CLBeaconRegion class]] ) {
        return NO;
    }
    
    if ([beaconRegion.identifier isEqualToString:region.identifier]) {
        return YES;
    }
    
    return NO;
/*
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
 */
}

- (BOOL)isEqualLocationRegion:(CLCircularRegion *)circularRegion targetRegion:(CLRegion *)region
{
    if (![region isKindOfClass:[CLCircularRegion class]]) {
        return NO;
    }
    
    if ([circularRegion.identifier isEqualToString:region.identifier]) {
        return YES;
    }
    
    return NO;
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

- (CLCircularRegion *)getMonitoringLocationRegion:(CLRegion *)region
{
    if (![region isKindOfClass:[CLCircularRegion class]]) {
        return nil;
    }
    
    CLCircularRegion *circularRegion = (CLCircularRegion *)region;
    
    for (CLRegion *monitorRegion in _locationManager.monitoredRegions) {
        if ([self isEqualLocationRegion:circularRegion targetRegion:monitorRegion]) {
            return (CLCircularRegion *)monitorRegion;
        }
    }
    
    for (CLRegion *monitorRegion in _regions) {
        if ([self isEqualLocationRegion:circularRegion targetRegion:monitorRegion]) {
            return (CLCircularRegion *)monitorRegion;
        }
    }
    
    return nil;
}

- (CLRegion *)getRegionWithIdentifier:(NSString *)identifier
{
    for (CLRegion *monitorRegion in _locationManager.monitoredRegions) {
        if ([monitorRegion.identifier isEqualToString:identifier]) {
            return monitorRegion;
        }
    }
    
    for (CLRegion *monitorRegion in _regions) {
        if ([monitorRegion.identifier isEqualToString:identifier]) {
            return monitorRegion;
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

- (BOOL)isMonitoringLocationRegion:(CLRegion *)region
{
    CLCircularRegion *circularRegion = [self getMonitoringLocationRegion:region];
    if (circularRegion) {
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
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        return NO;
    }
    
    return YES;
}

- (void)checkMonitoringRegion
{
    if ([self isMonitoringCapable]) {
        for (CLRegion *region in _regions) {
            if ([region isKindOfClass:[CBeaconRegion class]]) {
                CBeaconRegion *beaconRegion = (CBeaconRegion *)region;
                if (beaconRegion && !beaconRegion.isMonitoring) {
                    [self startBeaconRegionMonitoring:beaconRegion];
                }
            }
            if ([region isKindOfClass:[CLocationRegion class]]) {
                CLocationRegion *locationRegion = (CLocationRegion *)region;
                if (locationRegion && !locationRegion.isMonitoring) {
                    [self startLocationRegionMonitoring:locationRegion];
                }
            }
        }
    }
}

- (void)enterRegion:(CLRegion *)region
{
    CBDLog(@"Identifier %@", region.identifier);
    
    if ([self isMonitoringBeaconRegion:region]) {
        if (_allowRanging) {
            [_locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
        }
        
        if ([self.beaconReceviceDelegate respondsToSelector:@selector(didUpdateRegionEnter:)]) {
            [self.beaconReceviceDelegate didUpdateRegionEnter:region.identifier];
        }
    }
    else if ([self isMonitoringLocationRegion:region]) {
        if ([self.locationReceviceDelegate respondsToSelector:@selector(didUpdateRegionEnter:)]) {
            [self.locationReceviceDelegate didUpdateRegionEnter:region.identifier];
        }
    }
}

- (void)exitRegion:(CLRegion *)region
{
    CBDLog(@"Identifier %@", region.identifier);
    
    if ([self isMonitoringBeaconRegion:region]) {
        [_locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
        if ([self.beaconReceviceDelegate respondsToSelector:@selector(didUpdateRegionExit:)]) {
            [self.beaconReceviceDelegate didUpdateRegionExit:region.identifier];
        }
    }
    else if ([self isMonitoringLocationRegion:region]) {
        if ([self.locationReceviceDelegate respondsToSelector:@selector(didUpdateRegionExit:)]) {
            [self.locationReceviceDelegate didUpdateRegionExit:region.identifier];
        }
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
    
    if ([self.beaconReceviceDelegate respondsToSelector:@selector(didUpdatePeripheralState:)]) {
        [self.beaconReceviceDelegate didUpdatePeripheralState:peripheral.state];
    }
    else if ([self.locationReceviceDelegate respondsToSelector:@selector(didUpdatePeripheralState:)]) {
        [self.locationReceviceDelegate didUpdatePeripheralState:peripheral.state];
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
    
    if ([self.beaconReceviceDelegate respondsToSelector:@selector(didUpdateAuthorizationStatus:)]) {
        [self.beaconReceviceDelegate didUpdateAuthorizationStatus:status];
    }
    else if ([self.locationReceviceDelegate respondsToSelector:@selector(didUpdateAuthorizationStatus:)]) {
        [self.locationReceviceDelegate didUpdateAuthorizationStatus:status];
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
    [self enterRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self exitRegion:region];
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
    
    [self stopRegionMonitoring:region];
}

#pragma mark - CLLocationManagerDelegate - Ranging

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CBDLog(@"Identifier %@", region.identifier);
    
    if (![self isMonitoringBeaconRegion:region]) {
        return;
    }
    
    NSString *identifier = region.identifier;
    
    if ([self.beaconReceviceDelegate respondsToSelector:@selector(didRangeBeacons:identifier:)]) {
        [self.beaconReceviceDelegate didRangeBeacons:beacons identifier:identifier];
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    CBDLog(@"Identifier %@, Error %@", region.identifier, error);
    [_locationManager stopRangingBeaconsInRegion:region];
}

@end
