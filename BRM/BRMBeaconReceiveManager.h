//
//  BRMBeaconReceiveManager.h
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

@protocol BRMBeaconReceiveDelegate <NSObject>
@optional
- (void)didUpdatePeripheralState:(CBPeripheralManagerState)state;
- (void)didUpdateAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)startRegionMonitoring:(NSString *)identifier;
- (void)stopRegionMonitoring:(NSString *)identifier;
- (void)didRangeBeacons:(NSArray *)beacons identifier:(NSString *)identifier;
- (void)didUpdateRegionEnter:(NSString *)identifier;
- (void)didUpdateRegionExit:(NSString *)identifier;
@end

@interface BRMBeaconReceiveManager : NSObject <IBRMRegionBeaconDelegate>

@property (nonatomic) BOOL allowRanging;
@property (nonatomic, weak) id<BRMBeaconReceiveDelegate> delegate;

+ (BRMBeaconReceiveManager *)sharedManager;

- (void)monitorBeaconRegionWithUuid:(NSString *)uuid identifier:(NSString *)identifier;
- (void)monitorBeaconRegionWithUuid:(NSString *)uuid major:(CLBeaconMajorValue)major identifier:(NSString *)identifier;
- (void)monitorBeaconRegionWithUuid:(NSString *)uuid major:(CLBeaconMajorValue)major minor:(CLBeaconMajorValue)minor identifier:(NSString *)identifier;
- (void)ceaseMonitoringBeaconRegionWithIdentifer:(NSString *)identifier;

- (NSArray *)monitoringBeaconRegions;

@end
