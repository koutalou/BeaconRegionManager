//
//  CLocationReceiveManager.m
//  iBeaconComm
//
//  Created by koutalou on 2015/07/23.
//  Copyright (c) 2015年 KotaroKodama. All rights reserved.
//

#import "CBeacon.h"
#import "CLocationReceiveManager.h"

@interface CLocationReceiveManager ()
@property (nonatomic, strong) CRegionManager *regionManager;

@end

@implementation CLocationReceiveManager

+ (CLocationReceiveManager *)sharedManager
{
    static CLocationReceiveManager *sharedSingleton;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedSingleton = [[CLocationReceiveManager alloc] init];
    });
    
    return sharedSingleton;
}

- (id)init {
    self = [super init];
    if (self) {
        _regionManager = [CRegionManager sharedManager];
        _regionManager.locationReceviceDelegate = self;
    }
    return self;
}

- (void)monitorLocationRegionWithLatitude:(double)latitude longitude:(double)longitude distance:(NSInteger)distance identifier:(NSString *)identifier
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = latitude;
    coordinate.longitude = longitude;
    
    CLocationRegion *region = [[CLocationRegion alloc] initWithCenter:coordinate radius:distance identifier:identifier];
    [_regionManager startLocationRegionMonitoring:region];
}

- (void)ceaseMonitoringLocationRegionWithIdentifer:(NSString *)identifier
{
    CLRegion *region = [_regionManager getRegionWithIdentifier:identifier];
    if ([region isKindOfClass:[CLCircularRegion class]] || [region isKindOfClass:[CLocationRegion class]]) {
        [_regionManager stopRegionMonitoring:region];
    }
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
