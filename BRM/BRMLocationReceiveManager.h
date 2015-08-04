//
//  BRMLocationReceiveManager.h
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

/*
 * Delegates to the BRMLocationReceiveManager should implement this protocol.
 */
@protocol BRMLocationReceiveDelegate <NSObject>
@optional
- (void)didUpdatePeripheralState:(CBPeripheralManagerState)state;
- (void)didUpdateAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)startRegionMonitoring:(NSString *)identifier;
- (void)stopRegionMonitoring:(NSString *)identifier;
- (void)didUpdateRegionEnter:(NSString *)identifier;
- (void)didUpdateRegionExit:(NSString *)identifier;
@end

/**
 * 'BRMLocationReceiveManager' have convenience methods for receiving Location region event.
 */
@interface BRMLocationReceiveManager : NSObject <IBRMRegionLocationDelegate>

/**
 *  Singleton method, return the shared instance
 *
 *  @return shared instance of BRMLocationReceiveManager class
 */
+ (BRMLocationReceiveManager *)sharedManager;

/**
 *  Start monitoring location region.
 *
 *  @param latitude   latitude of region
 *  @param longitude  longitude of region
 *  @param distance   circule radius of region
 *  @param identifier identifier of region
 */
- (void)monitorLocationRegionWithLatitude:(double)latitude longitude:(double)longitude distance:(NSInteger)distance identifier:(NSString *)identifier;

/**
 * Returns the NSArray of monitoring location regions.
 *
 * @return The NSArray of BRMLocationRegion that is monitored region by CLLocationManager.
 */
- (NSArray *)getMonitoringLocationRegions;

/**
 *  The object is delegate of BRMLocationReceiveDelegate.
 */
@property (nonatomic, weak) id<BRMLocationReceiveDelegate> delegate;

@end
