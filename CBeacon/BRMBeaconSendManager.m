//
//  CBeaconSendManager.m
//  
//
//  Created by koutalou on 2015/07/18.
//
//

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
