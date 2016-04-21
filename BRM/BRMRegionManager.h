//
//  BRMRegionManager.h
//
//  Copyright (c) 2015 koutalou
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/**
 * 'BRMBeaconRegion' is a subclass of 'CLBeaconRegion' for manage Beacon Region information.
 */
@interface BRMBeaconRegion : CLBeaconRegion
//-----------------------------------------------------------------------------------------------
// BRMBeaconRegion
//-----------------------------------------------------------------------------------------------

@property (nonatomic) BOOL isMonitoring;
@property (nonatomic) BOOL entered;
@property (nonatomic, weak) NSArray *beacons;

@end

/**
 * 'BRMLocationRegion' is a subclass of 'CLCircularRegion' for manage Location Region information.
 */
@interface BRMLocationRegion : CLCircularRegion
//-----------------------------------------------------------------------------------------------
// BRMLocationRegion
//-----------------------------------------------------------------------------------------------

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
//LEI:pass the region object
- (void)didEnterRegion:(BRMBeaconRegion *)region;
- (void)didExitRegion:(BRMBeaconRegion *)region;
@end

@protocol IBRMRegionLocationDelegate <NSObject>
- (void)didUpdatePeripheralState:(CBPeripheralManagerState)state;
- (void)didUpdateAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)startRegionMonitoring:(NSString *)identifier;
- (void)stopRegionMonitoring:(NSString *)identifier;
- (void)didUpdateRegionEnter:(NSString *)identifier;
- (void)didUpdateRegionExit:(NSString *)identifier;
@end

/**
 * 'BRMRegionManager' is receiving region and ranging helper for BRMBeaconReceiveManager and BRMLocationReceiveManager.
 * Application should not use this class directly.
 */
@interface BRMRegionManager : NSObject <CBPeripheralManagerDelegate, CLLocationManagerDelegate>

/**
 *  Singleton method, return the shared instance
 *
 *  @return shared instance of BRMRegionManager class
 */
+ (BRMRegionManager *)sharedManager;

/**
 * Start region monitoring for beacon.
 *
 * @param beaconRegion The region for the beacon.
 */
- (void)startBeaconRegionMonitoring:(BRMBeaconRegion *)beaconRegion;

/**
 * Start region monitoring for location.
 *
 * @param beaconRegion the region for the location.
 */
- (void)startLocationRegionMonitoring:(BRMLocationRegion *)circularRegion;

/**
 * Stop region monitoring for beacon and location.
 *
 * @param region the region for beacon and location.
 */
- (void)stopRegionMonitoring:(CLRegion *)region;

/**
 * Return region of match the identifier.
 *
 * @param identifier identifier of the region.
 */
- (CLRegion *)getMonitoringRegionWithIdentifier:(NSString *)identifier;

@property (nonatomic, weak) id<IBRMRegionBeaconDelegate> beaconReceviceDelegate;
@property (nonatomic, weak) id<IBRMRegionLocationDelegate> locationReceviceDelegate;
@property (nonatomic) BOOL allowRanging;
@property (nonatomic, strong) NSMutableArray *monitoringBeaconRegions;
@property (nonatomic, strong) NSMutableArray *monitoringLocationRegions;

@end
