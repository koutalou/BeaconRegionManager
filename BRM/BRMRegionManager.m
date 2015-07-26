//
//  CRegionManager.m
//  iBeaconComm
//
//  Created by koutalou on 2015/07/23.
//  Copyright (c) 2015年 KotaroKodama. All rights reserved.
//

#import "BRMBeacon.h"
#import "BRMRegionManager.h"

@implementation BRMBeaconRegion
@end
@implementation BRMLocationRegion
@end

@interface BRMRegionManager ()
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *regions;

@end

@implementation BRMRegionManager

+ (BRMRegionManager *)sharedManager
{
    static BRMRegionManager *sharedSingleton;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedSingleton = [[BRMRegionManager alloc] init];
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
        
        [self initMonitoringRegions];
        
        float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (iOSVersion >= 8.0) {
            [self.locationManager requestAlwaysAuthorization];
        }
    }
    return self;
}

#pragma mark - Public function

- (void)startBeaconRegionMonitoring:(BRMBeaconRegion *)beaconRegion
{
    BRMBeaconRegion *sameBeaconRegion = [self getMonitoringBeaconRegion:beaconRegion];
    if (!sameBeaconRegion) {
        [_regions addObject:beaconRegion];
    }
    
    if (sameBeaconRegion.isMonitoring) {
        return;
    }
    
    if (![self isMonitoringCapable]) {
        return;
    }
    
    [_locationManager startMonitoringForRegion:beaconRegion];
    beaconRegion.isMonitoring = YES;
    [self addBRMRegion:beaconRegion];
    
    [_regions removeObject:beaconRegion];
    
    if ([self.beaconReceviceDelegate respondsToSelector:@selector(startRegionMonitoring:)]) {
        [self.beaconReceviceDelegate startRegionMonitoring:beaconRegion.identifier];
    }
}

- (void)startLocationRegionMonitoring:(BRMLocationRegion *)circularRegion
{
    BRMLocationRegion *sameLocationRegion = [self getMonitoringLocationRegion:circularRegion];
    if (!sameLocationRegion) {
        [_regions addObject:circularRegion];
    }
    
    if (sameLocationRegion.isMonitoring) {
        return;
    }
    
    if (![self isMonitoringCapable]) {
        return;
    }

    [_locationManager startMonitoringForRegion:circularRegion];
    circularRegion.isMonitoring = YES;
    [self addBRMRegion:circularRegion];
    
    [_regions removeObject:circularRegion];
    
    if ([self.locationReceviceDelegate respondsToSelector:@selector(startRegionMonitoring:)]) {
        [self.locationReceviceDelegate startRegionMonitoring:circularRegion.identifier];
    }
}

- (void)stopRegionMonitoring:(CLRegion *)region
{
    if ([self isMonitoringBeaconRegion:region]) {
        [_locationManager stopMonitoringForRegion:region];

        BRMBeaconRegion *beaconRegion = [self getMonitoringBeaconRegion:region];
        [_monitoringBeaconRegions removeObject:beaconRegion];
        
        if ([self.beaconReceviceDelegate respondsToSelector:@selector(stopRegionMonitoring:)]) {
            [self.beaconReceviceDelegate stopRegionMonitoring:region.identifier];
        }
    }
    if ([self isMonitoringLocationRegion:region]) {
        [_locationManager stopMonitoringForRegion:region];

        BRMLocationRegion *locationRegion = [self getMonitoringLocationRegion:region];
        [_monitoringBeaconRegions removeObject:locationRegion];
        
        if ([self.locationReceviceDelegate respondsToSelector:@selector(stopRegionMonitoring:)]) {
            [self.locationReceviceDelegate stopRegionMonitoring:region.identifier];
        }
    }
}

- (void)initMonitoringRegions
{
    _monitoringBeaconRegions = [@[] mutableCopy];

    for (CLRegion *region in _locationManager.monitoredRegions) {
        if ([region isKindOfClass:[CLBeaconRegion class]]) {
            CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
            BRMBeaconRegion *brmBeaconRegion;
            if (beaconRegion.major && beaconRegion.minor) {
                brmBeaconRegion = [[BRMBeaconRegion alloc] initWithProximityUUID:beaconRegion.proximityUUID major:[beaconRegion.major integerValue] minor:[beaconRegion.minor integerValue] identifier:beaconRegion.identifier];
            }
            else if (beaconRegion.major) {
                brmBeaconRegion = [[BRMBeaconRegion alloc] initWithProximityUUID:beaconRegion.proximityUUID major:[beaconRegion.major integerValue] identifier:beaconRegion.identifier];
            }
            else {
                brmBeaconRegion = [[BRMBeaconRegion alloc] initWithProximityUUID:beaconRegion.proximityUUID identifier:beaconRegion.identifier];
            }
            brmBeaconRegion.isMonitoring = YES;
            [_monitoringBeaconRegions addObject:brmBeaconRegion];
        }
        else if ([region isKindOfClass:[CLCircularRegion class]]) {
            CLCircularRegion *locationRegion = (CLCircularRegion *)region;
            BRMLocationRegion *brmLocationRegion = [[BRMLocationRegion alloc] initWithCenter:locationRegion.center radius:locationRegion.radius identifier:locationRegion.identifier];
            brmLocationRegion.isMonitoring = YES;
            [_monitoringLocationRegions addObject:brmLocationRegion];
        }
    }
}

- (void)addBRMRegion:(CLRegion *)region
{
    if ([region isKindOfClass:[BRMBeaconRegion class]]) {
        for (CLRegion *cmpRegion in _monitoringBeaconRegions) {
            if ([self isEqualBeaconRegion:(BRMBeaconRegion *)region targetRegion:cmpRegion]) {
                [_monitoringBeaconRegions addObject:region];
            }
        }
    }
    else if ([region isKindOfClass:[BRMLocationRegion class]]) {
        for (CLRegion *cmpRegion in _monitoringLocationRegions) {
            if ([self isEqualLocationRegion:(BRMLocationRegion *)region targetRegion:cmpRegion]) {
                [_monitoringLocationRegions addObject:region];
            }
        }
    }
}

#pragma mark - Public function for ReceiveManager

- (BOOL)isEqualBeaconRegion:(CLBeaconRegion *)beaconRegion targetRegion:(CLRegion *)region
{
    if (![region isKindOfClass:[CLBeaconRegion class]] ) {
        return NO;
    }
    
    if ([beaconRegion.identifier isEqualToString:region.identifier]) {
        return YES;
    }
    
    return NO;
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

- (BRMBeaconRegion *)getMonitoringBeaconRegion:(CLRegion *)region
{
    if (![region isKindOfClass:[CLBeaconRegion class]]) {
        return nil;
    }
    
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    for (CLRegion *monitoringRegion in _monitoringBeaconRegions) {
        if ([self isEqualBeaconRegion:beaconRegion targetRegion:monitoringRegion]) {
            return (BRMBeaconRegion *)monitoringRegion;
        }
    }

    return nil;
}

- (BRMLocationRegion *)getMonitoringLocationRegion:(CLRegion *)region
{
    if (![region isKindOfClass:[CLCircularRegion class]]) {
        return nil;
    }
    
    CLCircularRegion *circularRegion = (CLCircularRegion *)region;
    for (CLRegion *monitoringRegion in _monitoringLocationRegions) {
        if ([self isEqualLocationRegion:circularRegion targetRegion:monitoringRegion]) {
            return (BRMLocationRegion *)monitoringRegion;
        }
    }
    
    return nil;
}

- (CLRegion *)getMonitoringRegionWithIdentifier:(NSString *)identifier
{
    for (CLRegion *monitorRegion in _locationManager.monitoredRegions) {
        if ([monitorRegion.identifier isEqualToString:identifier]) {
            return monitorRegion;
        }
    }

    return nil;
}

- (BOOL)isMonitoringBeaconRegion:(CLRegion *)region
{
    BRMBeaconRegion *beaconRegion = [self getMonitoringBeaconRegion:region];
    if (beaconRegion) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isMonitoringLocationRegion:(CLRegion *)region
{
    BRMLocationRegion *circularRegion = [self getMonitoringLocationRegion:region];
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
            if ([region isKindOfClass:[BRMBeaconRegion class]]) {
                BRMBeaconRegion *beaconRegion = (BRMBeaconRegion *)region;
                if (beaconRegion && !beaconRegion.isMonitoring) {
                    [self startBeaconRegionMonitoring:beaconRegion];
                }
            }
            if ([region isKindOfClass:[BRMLocationRegion class]]) {
                BRMLocationRegion *locationRegion = (BRMLocationRegion *)region;
                if (locationRegion && !locationRegion.isMonitoring) {
                    [self startLocationRegionMonitoring:locationRegion];
                }
            }
        }
    }
}

- (void)enterRegion:(CLRegion *)region
{
    BRMDLog(@"Identifier %@", region.identifier);
    
    if ([self isMonitoringBeaconRegion:region]) {
        BRMBeaconRegion *beaconRegion = [self getMonitoringBeaconRegion:region];
        beaconRegion.entered = YES;
        
        if (_allowRanging) {
            [_locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
        }
        
        if ([self.beaconReceviceDelegate respondsToSelector:@selector(didUpdateRegionEnter:)]) {
            [self.beaconReceviceDelegate didUpdateRegionEnter:region.identifier];
        }
    }
    else if ([self isMonitoringLocationRegion:region]) {
        BRMLocationRegion *locationRegion = [self getMonitoringLocationRegion:region];
        locationRegion.entered = YES;

        if ([self.locationReceviceDelegate respondsToSelector:@selector(didUpdateRegionEnter:)]) {
            [self.locationReceviceDelegate didUpdateRegionEnter:region.identifier];
        }
    }
}

- (void)exitRegion:(CLRegion *)region
{
    BRMDLog(@"Identifier %@", region.identifier);
    
    if ([self isMonitoringBeaconRegion:region]) {
        BRMBeaconRegion *beaconRegion = [self getMonitoringBeaconRegion:region];
        beaconRegion.entered = NO;
        beaconRegion.beacons = nil;
        
        [_locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
        if ([self.beaconReceviceDelegate respondsToSelector:@selector(didUpdateRegionExit:)]) {
            [self.beaconReceviceDelegate didUpdateRegionExit:region.identifier];
        }
    }
    else if ([self isMonitoringLocationRegion:region]) {
        BRMLocationRegion *locationRegion = [self getMonitoringLocationRegion:region];
        locationRegion.entered = NO;

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
    BRMDLog(@"Peripheral state %@", [self peripheralStateString:peripheral.state]);
    
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
    BRMDLog(@"Status %@", [self locationAuthorizationStatusString:status]);
    
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
    BRMDLog(@"Identifier %@", region.identifier);
    
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
    BRMDLog(@"Region %@, Identifier: %@", [self regionStateString:state], region.identifier);
    
    if ([self isMonitoringBeaconRegion:region]) {
        switch (state) {
            case CLRegionStateInside:
                [self enterRegion:region];
                break;
            case CLRegionStateOutside:
            case CLRegionStateUnknown:
                [self exitRegion:region];
                break;
            default:
                break;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    BRMDLog(@"Identifier %@, Error %@", region.identifier, error);
    
    [self stopRegionMonitoring:region];
}

#pragma mark - CLLocationManagerDelegate - Ranging

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    BRMDLog(@"Identifier %@", region.identifier);
    
    if (![self isMonitoringBeaconRegion:region]) {
        return;
    }
    
    NSString *identifier = region.identifier;
    
    BRMBeaconRegion *beaconRegion = [self getMonitoringBeaconRegion:region];
    beaconRegion.beacons = beacons;
    
    if ([self.beaconReceviceDelegate respondsToSelector:@selector(didRangeBeacons:identifier:)]) {
        [self.beaconReceviceDelegate didRangeBeacons:beacons identifier:identifier];
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    BRMDLog(@"Identifier %@, Error %@", region.identifier, error);
    [_locationManager stopRangingBeaconsInRegion:region];
}

@end
