//
//  BRMBeaconSendManager.m
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

#import "BRMBeacon.h"
#import "BRMBeaconSendManager.h"

@interface BRMBeaconSendManager ()
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CLBeaconRegion *beaconSendRegion;

@end

@implementation BRMBeaconSendManager

+ (BRMBeaconSendManager *)sharedManager
{
    static BRMBeaconSendManager *sharedSingleton;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedSingleton = [[BRMBeaconSendManager alloc] init];
    });
    
    return sharedSingleton;
}

- (id)init {
    self = [super init];
    if (self) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (void)startBeaconWithUUID:(NSString *)uuid identifier:(NSString *)identifier major:(int)major minor:(int)minor second:(int)second
{
    if (_peripheralManager.isAdvertising) {
        return;
    }
    
    NSUUID *proxymityUUID = [[NSUUID alloc] initWithUUIDString:uuid];
    _beaconSendRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proxymityUUID major:major minor:minor identifier:identifier];
    [_beaconSendRegion peripheralDataWithMeasuredPower:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stopBeacon];
    });
}

- (void)stopBeacon
{
    [_peripheralManager stopAdvertising];
}

#pragma mark - CLPeripheralManager Delegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            // Advertise iBeacon Signal
            [_peripheralManager startAdvertising:[_beaconSendRegion peripheralDataWithMeasuredPower:nil]];
            break;
        case CBPeripheralManagerStatePoweredOff:
        case CBPeripheralManagerStateResetting:
        case CBPeripheralManagerStateUnauthorized:
        case CBPeripheralManagerStateUnsupported:
        case CBPeripheralManagerStateUnknown:
            BRMDLog(@"Not Ready: Peripheral State %ld", peripheral.state);
            break;
        default:
            break;
    }
}


@end
