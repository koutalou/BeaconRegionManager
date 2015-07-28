//
//  BRMEddystoneReceiveManager.h
//  BRMExample
//
//  Created by koutalou on 2015/07/28.
//  Copyright (c) 2015年 koutalou. All rights reserved.
//

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
