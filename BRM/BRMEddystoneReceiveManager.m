//
//  BRMEddystoneReceiveManager.m
//  BRMExample
//
//  Created by koutalou on 2015/07/28.
//  Copyright (c) 2015年 koutalou. All rights reserved.
//

#import "BRMBeacon.h"
#import "BRMEddystoneReceiveManager.h"

@implementation BRMEddystoneBeacon

@end

@implementation BRMEddystoneUIDBeacon

- (BRMEddystoneUIDBeacon *)initWithAdvertiseData:(NSData *)advertiseData
{
    self = [super init];
    self.advertiseData = [advertiseData copy];
    
    unsigned long advertiseDataSize = advertiseData.length;
    
    if (self) {
        if (advertiseDataSize < 20) {
            return nil;
        }
        
        const unsigned char *cData = [advertiseData bytes];
        unsigned char *data;
        
        // Malloc advertise data for char*
        data = malloc(sizeof(unsigned char) * advertiseDataSize);
        if (!data) {
            return nil;
        }
        
        for (int i = 0; i < advertiseDataSize; i++) {
            data[i] = *cData++;
        }
        
        unsigned char txPowerChar = *(data+1);
        if (txPowerChar & 0xf0) {
            self.txPower = [NSNumber numberWithInt:(- 0x100 + txPowerChar)];
        }
        else {
            self.txPower = [NSNumber numberWithInt:txPowerChar];
        }
        
        self.namespaceId = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",*(data+2), *(data+3), *(data+4), *(data+5), *(data+6), *(data+7), *(data+8), *(data+9), *(data+10), *(data+11)];
        self.instanceId = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x",*(data+12), *(data+13), *(data+14), *(data+15), *(data+16), *(data+17)];
        
        // Free advertise data for char*
        free(data);
    }
    return self;
}

@end

@implementation BRMEddystoneURLBeacon

- (NSString *)getUrlscheme:(char)hexChar
{
    switch (hexChar) {
        case 0x00:
            return @"http://www.";
        case 0x01:
            return @"https://www.";
        case 0x02:
            return @"http://";
        case 0x03:
            return @"https://";
        default:
            return nil;
    }
}

- (NSString *)getEncodedString:(char)hexChar
{
    switch (hexChar) {
            
        case 0x00:
            return @".com/";
        case 0x01:
            return @".org/";
        case 0x02:
            return @".edu/";
        case 0x03:
            return @".net/";
        case 0x04:
            return @".info/";
        case 0x05:
            return @".biz/";
        case 0x06:
            return @".gov/";
        case 0x07:
            return @".com";
        case 0x08:
            return @".org";
        case 0x09:
            return @".edu";
        case 0x0a:
            return @".net";
        case 0x0b:
            return @".info";
        case 0x0c:
            return @".biz";
        case 0x0d:
            return @".gov";
        default:
            return [NSString stringWithFormat:@"%c", hexChar];
    }
}

- (BRMEddystoneURLBeacon *)initWithAdvertiseData:(NSData *)advertiseData
{
    self = [super init];
    self.advertiseData = [advertiseData copy];
    
    unsigned long advertiseDataSize = advertiseData.length;
    
    if (self) {
        if (advertiseDataSize < 3) {
            return nil;
        }
        
        const unsigned char *cData = [advertiseData bytes];
        unsigned char *data;
        
        // Malloc advertise data for char*
        data = malloc(sizeof(unsigned char) * advertiseDataSize);
        if (!data) {
            return nil;
        }
        
        for (int i = 0; i < advertiseDataSize; i++) {
            data[i] = *cData++;
        }
        
        unsigned char txPowerChar = *(data+1);
        if (txPowerChar & 0xf0) {
            self.txPower = [NSNumber numberWithInt:(- 0x100 + txPowerChar)];
        }
        else {
            self.txPower = [NSNumber numberWithInt:txPowerChar];
        }
        
        NSString *urlScheme = [self getUrlscheme:*(data+2)];
        
        NSString *url = urlScheme;
        for (int i = 0; i < advertiseDataSize - 3; i++) {
            url = [url stringByAppendingString:[self getEncodedString:*(data + i + 3)]];
        }
        self.shortUrl = url;

        // Free advertise data for char*
        free(data);
    }
    return self;
}

@end

@implementation BRMEddystoneTLMBeacon

- (BRMEddystoneTLMBeacon *)initWithAdvertiseData:(NSData *)advertiseData
{
    self = [super init];
    self.advertiseData = [advertiseData copy];
    
    unsigned long advertiseDataSize = advertiseData.length;
    
    if (self) {
        if (advertiseDataSize < 14) {
            return nil;
        }
        
        const unsigned char *cData = [advertiseData bytes];
        unsigned char *data;
        
        // Malloc advertise data for char*
        data = malloc(sizeof(unsigned char) * advertiseDataSize);
        if (!data) {
            return nil;
        }
        
        for (int i = 0; i < advertiseDataSize; i++) {
            data[i] = *cData++;
        }
        
        /* [TDOO] Set TML Beacon Properties */
        self.version = [NSNumber numberWithInt:*(data+1)];
        self.mvPerbit = [NSNumber numberWithInt:(*(data+2) + (*(data+3) << 4))];
        
        unsigned char temperatureInt = *(data+5);
        if (temperatureInt & 0xf0) {
            self.temperature = [NSNumber numberWithFloat:(float)(- 0x100 + temperatureInt) + *(data+4) / 256.0];
        }
        else {
            self.temperature = [NSNumber numberWithFloat:(float)temperatureInt + *(data+4) / 256.0];
        }
        self.advertiseCount = [NSNumber numberWithLong:(*(data+6) + (*(data+7) << 4) + (*(data+8) << 8) + (*(data+9) << 12))];
        self.advertiseCount = [NSNumber numberWithLong:(*(data+6) + (*(data+7) << 4) + (*(data+8) << 8) + (*(data+9) << 12))];
        self.deciSecondsSinceBoot = [NSNumber numberWithDouble:((*(data+10) + (*(data+11) << 4) + (*(data+12) << 8) + (*(data+13) << 12)) / 10.0)];
        
        // Free advertise data for char*
        free(data);
    }
    return self;
}

@end

@interface BRMEddystoneReceiveManager ()

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, weak) NSTimer *checkTimer;

@end

@implementation BRMEddystoneReceiveManager

+ (BRMEddystoneReceiveManager *)sharedManager
{
    static BRMEddystoneReceiveManager *sharedSingleton;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedSingleton = [[BRMEddystoneReceiveManager alloc] init];
    });
    
    return sharedSingleton;
}

- (id)init {
    self = [super init];
    if (self) {
        [self startMonitoringEddystoneBeacon];
        _monitoringEddystoneBeacons = [@[] mutableCopy];
    }
    
    return self;
}

- (void)startMonitoringEddystoneBeacon
{
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (BRMFrameType)getFrameTypeWithAdvertiseData:(NSData *)advertiseData
{
    unsigned long advertiseDataSize = advertiseData.length;
    
    if (advertiseDataSize == 0) {
        return kBRMEddystoneUnknownFrameType;
    }
    
    const unsigned char *cData = [advertiseData bytes];
    
    if (*cData == 0x00) {
        return kBRMEddystoneUIDFrameType;
    }
    else if (*cData == 0x10) {
        return kBRMEddystoneURLFrameType;
    }
    else if (*cData == 0x20) {
        return kBRMEddystoneTLMFrameType;
    }
    
    return kBRMEddystoneUnknownFrameType;
}

- (BRMEddystoneBeacon *)getFoundSameBeacon:(BRMEddystoneBeacon *)eddystoneBeacon
{
    for (BRMEddystoneBeacon *cmpBeacon in _monitoringEddystoneBeacons) {
        if (![eddystoneBeacon.identifier isEqualToString:cmpBeacon.identifier]) {
            continue;
        }
        if (eddystoneBeacon.frameType != cmpBeacon.frameType) {
            continue;
        }
        
        return cmpBeacon;
    }
    
    return nil;
}

- (void)checkAdvertiseNoLonger
{
    NSDate *date = [NSDate date];
    
    for (BRMEddystoneBeacon *eddystoneBeacon in _monitoringEddystoneBeacons) {
        NSTimeInterval passedTime = [date timeIntervalSinceDate:eddystoneBeacon.lastUpdateDate];
        if (passedTime > 10.0) {
            [self exitBeacon:eddystoneBeacon];
            [_monitoringEddystoneBeacons removeObject:eddystoneBeacon];
        }
    }
    
    if (_monitoringEddystoneBeacons.count == 0) {
        [_checkTimer invalidate];
        _checkTimer = nil;
    }
}

- (void)checkEddystoneBeaconsStatus
{
    [self checkAdvertiseNoLonger];
    
    if ([_delegate respondsToSelector:@selector(didRangeBeacons:)]) {
        [_delegate didRangeBeacons:_monitoringEddystoneBeacons];
    }
}

- (void)updateBeacon:(BRMEddystoneBeacon *)eddystoneBeacon rssi:(NSNumber *)rssi
{
    if (!_checkTimer) {
        _checkTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(checkEddystoneBeaconsStatus) userInfo:nil repeats:YES];
    }
    
    BRMEddystoneBeacon *sameBeacon = [self getFoundSameBeacon:eddystoneBeacon];
    if (sameBeacon) {
        // Update Beacon
        
        // RSSI 127 is Error case
        if ([rssi integerValue] != 127) {
            [sameBeacon.rssis addObject:rssi];
            if (sameBeacon.rssis.count >10) {
                [sameBeacon.rssis removeObjectAtIndex:0];
            }
            
            float average = 0;
            for (NSNumber *rssi in sameBeacon.rssis) {
                average = average + [rssi integerValue];
            }
            average = average / sameBeacon.rssis.count;
            sameBeacon.averageRssi = [NSNumber numberWithFloat:average];
        }
        
        sameBeacon.lastUpdateDate = [NSDate date];
        
        // No update other date because it's always same value for Eddystone specification.
    }
    else {
        // Found New Beacon
        eddystoneBeacon.rssis = [@[rssi] mutableCopy];
        
        // RSSI 127 is Error case
        if ([rssi integerValue] != 127) {
            eddystoneBeacon.averageRssi = rssi;
        }
        [_monitoringEddystoneBeacons addObject:eddystoneBeacon];

        eddystoneBeacon.lastUpdateDate = [NSDate date];

        [self enterBeacon:eddystoneBeacon];
    }
}

- (CBUUID *)getEddystoneServiceID {
    static CBUUID *_singleton;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _singleton = [CBUUID UUIDWithString:kBRMEddystoneServiceID];
    });
    
    return _singleton;
}

- (void)enterBeacon:(BRMEddystoneBeacon *)eddystoneBeacon
{
    switch (eddystoneBeacon.frameType) {
        case kBRMEddystoneUIDFrameType:
        {
            if ([_delegate respondsToSelector:@selector(didUpdateEnterUIDBeacon:)]) {
                [_delegate didUpdateEnterUIDBeacon:(BRMEddystoneUIDBeacon *)eddystoneBeacon];
            }
            break;
        }
        case kBRMEddystoneURLFrameType:
        {
            if ([_delegate respondsToSelector:@selector(didUpdateEnterURLBeacon:)]) {
                [_delegate didUpdateEnterURLBeacon:(BRMEddystoneURLBeacon *)eddystoneBeacon];
            }
            break;
        }
        case kBRMEddystoneTLMFrameType:
        {
            if ([_delegate respondsToSelector:@selector(didUpdateEnterTLMBeacon:)]) {
                [_delegate didUpdateEnterTLMBeacon:(BRMEddystoneTLMBeacon *)eddystoneBeacon];
            }
            break;
        }
        default:
            break;
    }
}

- (void)exitBeacon:(BRMEddystoneBeacon *)eddystoneBeacon
{
    switch (eddystoneBeacon.frameType) {
        case kBRMEddystoneUIDFrameType:
        {
            if ([_delegate respondsToSelector:@selector(didUpdateExitUIDBeacon:)]) {
                [_delegate didUpdateExitUIDBeacon:(BRMEddystoneUIDBeacon *)eddystoneBeacon];
            }
            break;
        }
        case kBRMEddystoneURLFrameType:
        {
            if ([_delegate respondsToSelector:@selector(didUpdateExitURLBeacon:)]) {
                [_delegate didUpdateExitURLBeacon:(BRMEddystoneURLBeacon *)eddystoneBeacon];
            }
            break;
        }
        case kBRMEddystoneTLMFrameType:
        {
            if ([_delegate respondsToSelector:@selector(didUpdateExitTLMBeacon:)]) {
                [_delegate didUpdateExitTLMBeacon:(BRMEddystoneTLMBeacon *)eddystoneBeacon];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - CentralManager Delegate

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    BRMDLog(@"RSSI: %@\nAdvertisementData: %@", RSSI, advertisementData);
    
    NSDictionary *advertiseDataDictionay = [advertisementData objectForKey:CBAdvertisementDataServiceDataKey];
    NSData *advertiseData = advertiseDataDictionay[[self getEddystoneServiceID]];
    
    BRMFrameType frameType = [self getFrameTypeWithAdvertiseData:advertiseData];

    switch (frameType) {
        case kBRMEddystoneUIDFrameType:
        {
            BRMEddystoneUIDBeacon *uidBeacon = [[BRMEddystoneUIDBeacon alloc] initWithAdvertiseData:advertiseData];
            uidBeacon.frameType = frameType;
            uidBeacon.identifier = peripheral.identifier.UUIDString;
            [self updateBeacon:uidBeacon rssi:RSSI];
            break;
        }
        case kBRMEddystoneURLFrameType:
        {
            BRMEddystoneURLBeacon *urlBeacon = [[BRMEddystoneURLBeacon alloc] initWithAdvertiseData:advertiseData];
            urlBeacon.frameType = frameType;
            urlBeacon.identifier = peripheral.identifier.UUIDString;
            [self updateBeacon:urlBeacon rssi:RSSI];
            break;
        }
        case kBRMEddystoneTLMFrameType:
        {
            BRMEddystoneTLMBeacon *tlmBeacon = [[BRMEddystoneTLMBeacon alloc] initWithAdvertiseData:advertiseData];
            tlmBeacon.frameType = frameType;
            tlmBeacon.identifier = peripheral.identifier.UUIDString;
            [self updateBeacon:tlmBeacon rssi:RSSI];
            break;
        }
        default:
            // Unknown Eddystone Beacon or Vendor Customize Eddystone Beacon
            break;
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    BRMDLog(@"State: %ld", central.state);
    
    NSArray *services = @[[CBUUID UUIDWithString:kBRMEddystoneServiceID]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    if (_centralManager.state == CBCentralManagerStatePoweredOn) {
        [_centralManager scanForPeripheralsWithServices:services options:options];
    }
    
    return;
}

@end
