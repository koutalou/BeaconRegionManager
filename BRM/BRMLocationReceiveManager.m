//
//  CLocationReceiveManager.m
//  iBeaconComm
//
//  Created by koutalou on 2015/07/23.
//  Copyright (c) 2015年 KotaroKodama. All rights reserved.
//

#import "BRMBeacon.h"
#import "BRMLocationReceiveManager.h"

@interface BRMLocationReceiveManager ()
@property (nonatomic, strong) BRMRegionManager *regionManager;

@end

@implementation BRMLocationReceiveManager

+ (BRMLocationReceiveManager *)sharedManager
{
    static BRMLocationReceiveManager *sharedSingleton;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedSingleton = [[BRMLocationReceiveManager alloc] init];
    });
    
    return sharedSingleton;
}

- (id)init {
    self = [super init];
    if (self) {
        _regionManager = [BRMRegionManager sharedManager];
        _regionManager.locationReceviceDelegate = self;
    }
    return self;
}

- (void)monitorLocationRegionWithLatitude:(double)latitude longitude:(double)longitude distance:(NSInteger)distance identifier:(NSString *)identifier
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = latitude;
    coordinate.longitude = longitude;
    
    BRMLocationRegion *region = [[BRMLocationRegion alloc] initWithCenter:coordinate radius:distance identifier:identifier];
    [_regionManager startLocationRegionMonitoring:region];
}

- (void)ceaseMonitoringLocationRegionWithIdentifer:(NSString *)identifier
{
    CLRegion *region = [_regionManager getMonitoringRegionWithIdentifier:identifier];
    if ([region isKindOfClass:[CLCircularRegion class]] || [region isKindOfClass:[BRMLocationRegion class]]) {
        [_regionManager stopRegionMonitoring:region];
    }
}

- (NSArray *)getMonitoringLocationRegions
{
    return _regionManager.monitoringLocationRegions;
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
