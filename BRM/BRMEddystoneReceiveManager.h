//
//  BRMEddystoneReceiveManager.h
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
#import <CoreBluetooth/CoreBluetooth.h>

static NSString *const kBRMEddystoneServiceID = @"FEAA";

typedef NS_ENUM(NSUInteger, BRMFrameType) {
    kBRMEddystoneUIDFrameType = 0,
    kBRMEddystoneURLFrameType = 1,
    kBRMEddystoneTLMFrameType = 2,
    kBRMEddystoneUnknownFrameType = 3
};

@interface BRMEddystoneBeacon : NSObject

@property (nonatomic) NSInteger frameType;
@property (nonatomic) NSData *advertiseData;
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSMutableArray *rssis;
@property (nonatomic) NSNumber *averageRssi;
@property (nonatomic) NSDate *lastUpdateDate;

@end

@interface BRMEddystoneUIDBeacon : BRMEddystoneBeacon

@property (nonatomic) NSNumber *txPower;
@property (nonatomic) NSString *namespaceId;
@property (nonatomic) NSString *instanceId;

- (BRMEddystoneUIDBeacon *)initWithAdvertiseData:(NSData *)advertiseData;

@end

@interface BRMEddystoneURLBeacon : BRMEddystoneBeacon

@property (nonatomic) NSNumber *txPower;
@property (nonatomic) NSString *shortUrl;

- (BRMEddystoneURLBeacon *)initWithAdvertiseData:(NSData *)advertiseData;

@end

@interface BRMEddystoneTLMBeacon : BRMEddystoneBeacon

@property (nonatomic) NSNumber *version;
@property (nonatomic) NSNumber *mvPerbit;
@property (nonatomic) NSNumber *temperature;
@property (nonatomic) NSNumber *advertiseCount;
@property (nonatomic) NSNumber *deciSecondsSinceBoot;

- (BRMEddystoneTLMBeacon *)initWithAdvertiseData:(NSData *)advertiseData;

@end

@protocol BRMEddystoneReceiveDelegate <NSObject>
@optional
- (void)didRangeBeacons:(NSArray *)beacons;
- (void)didUpdateEnterUIDBeacon:(BRMEddystoneUIDBeacon *)brmUIDBeacon;
- (void)didUpdateEnterURLBeacon:(BRMEddystoneURLBeacon *)brmURLBeacon;
- (void)didUpdateEnterTLMBeacon:(BRMEddystoneTLMBeacon *)brmTLMBeacon;
- (void)didUpdateExitUIDBeacon:(BRMEddystoneUIDBeacon *)brmUIDBeacon;
- (void)didUpdateExitURLBeacon:(BRMEddystoneURLBeacon *)brmURLBeacon;
- (void)didUpdateExitTLMBeacon:(BRMEddystoneTLMBeacon *)brmTLMBeacon;
@end

@interface BRMEddystoneReceiveManager : NSObject <CBCentralManagerDelegate>

+ (BRMEddystoneReceiveManager *)sharedManager;

- (void)startMonitoringEddystoneBeacon;

@property (nonatomic, weak) id<BRMEddystoneReceiveDelegate> delegate;
@property (readonly) NSMutableArray *monitoringEddystoneBeacons;

@end
