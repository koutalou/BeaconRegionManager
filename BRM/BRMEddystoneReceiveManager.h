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

/**
 * Eddystones Bluetooth Service ID.
 */
static NSString *const kBRMEddystoneServiceID = @"FEAA";

/**
 * Eddystones have three frame types.
 * See the Eddystone specification for complete details.
 */
typedef NS_ENUM(NSUInteger, BRMFrameType) {
    kBRMEddystoneUIDFrameType = 0,
    kBRMEddystoneURLFrameType = 1,
    kBRMEddystoneTLMFrameType = 2,
    kBRMEddystoneUnknownFrameType = 3
};


/**
 * 'BRMEddystoneBeacon' is a superclass for manage eddystone information.
 */
@interface BRMEddystoneBeacon : NSObject
//-----------------------------------------------------------------------------------------------
// BRMEddystoneBeacon
//-----------------------------------------------------------------------------------------------

@property (nonatomic) NSInteger frameType;
@property (nonatomic) NSData *advertiseData;
@property (nonatomic) NSString *identifier;
@property (nonatomic) NSMutableArray *rssis;
@property (nonatomic) NSNumber *averageRssi;
@property (nonatomic) NSDate *lastUpdateDate;

@end

/**
 * 'BRMEddystoneUIDBeacon' is a subclass of 'BRMEddystoneBeacon' for manage Eddystone-UID information.
 */
@interface BRMEddystoneUIDBeacon : BRMEddystoneBeacon
//-----------------------------------------------------------------------------------------------
// BRMEddystoneUIDBeacon
//-----------------------------------------------------------------------------------------------

@property (nonatomic) NSNumber *txPower;
@property (nonatomic) NSString *namespaceId;
@property (nonatomic) NSString *instanceId;

/**
 Initializes an 'BRMEddystoneUIDBeacon' object with the advertiseData.
 
 @param advertiseData The advertised data.
 
 @return The newly-initialized Eddystone-UID instance.
 */
- (BRMEddystoneUIDBeacon *)initWithAdvertiseData:(NSData *)advertiseData;

@end

/**
 * 'BRMEddystoneURLBeacon' is a subclass of 'BRMEddystoneBeacon' for manage Eddystone-URL information.
 */
@interface BRMEddystoneURLBeacon : BRMEddystoneBeacon
//-----------------------------------------------------------------------------------------------
// BRMEddystoneURLBeacon
//-----------------------------------------------------------------------------------------------

@property (nonatomic) NSNumber *txPower;
@property (nonatomic) NSString *shortUrl;

/**
 Initializes an 'BRMEddystoneURLBeacon' object with the advertiseData.
 
 @param advertiseData The advertised data.
 
 @return The newly-initialized Eddystone-URL instance.
 */
- (BRMEddystoneURLBeacon *)initWithAdvertiseData:(NSData *)advertiseData;

@end

/**
 * 'BRMEddystoneTLMBeacon' is a subclass of 'BRMEddystoneBeacon' for manage Eddystone-TLM information.
 */
@interface BRMEddystoneTLMBeacon : BRMEddystoneBeacon
//-----------------------------------------------------------------------------------------------
// BRMEddystoneTLMBeacon
//-----------------------------------------------------------------------------------------------

@property (nonatomic) NSNumber *version;
@property (nonatomic) NSNumber *mvPerbit;
@property (nonatomic) NSNumber *temperature;
@property (nonatomic) NSNumber *advertiseCount;
@property (nonatomic) NSNumber *deciSecondsSinceBoot;

/**
 Initializes an 'BRMEddystoneTLMBeacon' object with the advertiseData.
 
 @param advertiseData The advertised data.
 
 @return The newly-initialized Eddystone-TLM instance.
 */
- (BRMEddystoneTLMBeacon *)initWithAdvertiseData:(NSData *)advertiseData;

@end

/*
 * Delegates to the BRMEddystoneReceiveManager should implement this protocol.
 */
@protocol BRMEddystoneReceiveDelegate <NSObject>
@optional
- (void)didRangeBeacons:(NSArray *)beacons;
- (void)didUpdateBeacon:(BRMEddystoneBeacon *)beacon;
- (void)didUpdateEnterUIDBeacon:(BRMEddystoneUIDBeacon *)brmUIDBeacon;
- (void)didUpdateEnterURLBeacon:(BRMEddystoneURLBeacon *)brmURLBeacon;
- (void)didUpdateEnterTLMBeacon:(BRMEddystoneTLMBeacon *)brmTLMBeacon;
- (void)didUpdateExitUIDBeacon:(BRMEddystoneUIDBeacon *)brmUIDBeacon;
- (void)didUpdateExitURLBeacon:(BRMEddystoneURLBeacon *)brmURLBeacon;
- (void)didUpdateExitTLMBeacon:(BRMEddystoneTLMBeacon *)brmTLMBeacon;
@end

/**
 * 'BRMEddystoneReceiveManager' have convenience methods for receiving Eddystone advertise signal.
 */
@interface BRMEddystoneReceiveManager : NSObject <CBCentralManagerDelegate>

/**
 *  Singleton method, return the shared instance
 *
 *  @return shared instance of BRMEddystoneReceiveManager class
 */
+ (BRMEddystoneReceiveManager *)sharedManager;

/**
 *  Start monitoring for Eddystone beacon.
 */
- (void)startMonitoringEddystoneBeacon;

/**
 *  The object is delegate of BRMEddystoneReceiveDelegate.
 */
@property (nonatomic, weak) id<BRMEddystoneReceiveDelegate> delegate;

/**
 * Returns the NSArray of monitoring Eddystone beacons.
 *
 * @return The NSArray of BRMEddystoneBeacon(BRMEddystoneUIDBeacon, BRMEddystoneURLBeacon, BRMEddystoneTLMBeacon) that is monitored.
 */
@property (readonly) NSMutableArray *monitoringEddystoneBeacons;

@end
