# Beacon Region Manager

[![Pod Version](http://img.shields.io/cocoapods/v/BeaconRegionManager.svg?style=flat)](http://cocoadocs.org/docsets/BeaconRegionManager/)
[![Pod Platform](http://img.shields.io/cocoapods/p/BeaconRegionManager.svg?style=flat)](http://cocoadocs.org/docsets/BeaconRegionManager/)
[![Pod License](http://img.shields.io/cocoapods/l/BeaconRegionManager.svg?style=flat)](http://opensource.org/licenses/MIT)

Beacon Region Manager is wrapper library for Region monitoring of geographical regions and beacon regions API, Sending iBeacon signal.

# Requirements

* You have added the .h/m files to your project.

* Add 'NSLocationAlwaysUsageDescription' into your project Info.plist

# Usage

```objective-c
#import "BRMBeacon.h"
```

include all of necessary classes.

BRMBeaconSendManger, BRMBeaconReceiveManager, BRMLocationReceivceManger will instanciate singleton after called sharedManager.

## Send iBeacon signal

```objective-c
[[BRMBeaconSendManager sharedManager] startBeaconWithUUID:@"2290B76D-300E-40C1-A40A-38D28477ADCB" identifier:@"BRMBeacon" major:100 minor:100 second:5.0];
```

## Receive iBeacon region monitoring and ranging.

```objective-c
BRMBeaconReceiveManager *beaconReceiveManager = [BRMBeaconReceiveManager sharedManager];
beaconReceiveManager.delegate = self;
beaconReceiveManager monitorBeaconRegionWithUuid:@"2290B76D-300E-40C1-A40A-38D28477ADCB" identifier:@"BRMBeacon"];
```

You can disable iBeacon ranging. (Default:enable)

```objective-c
beaconReceiveManager.allowRanging = NO;
```

You need to inherit BRMBeaconReceiveDelegate to set delegation.

```objective-c
@interface MyClass : NSObject<BRMBeaconReceiveDelegate>
```

Region monitoring delegates defined in BRMBeaconReceiveDelegate,

```objective-c
- (void)didUpdateRegionEnter:(NSString *)identifier;
- (void)didUpdateRegionExit:(NSString *)identifier;
```

Ranging delegates defined in BRMBeaconReceiveDelegate,

```objective-c
- (void)didRangeBeacons:(NSArray *)beacons identifier:(NSString *)identifier;
```

A device can not receive own iBeacon signal.

## Receive location region monitoring.

```objective-c
BRMLocationReceiveManager *locationReceiveManager = [BRMLocationReceiveManager sharedManager];
locationReceiveManager.delegate = self;
locationReceiveManager monitorLocationRegionWithLatitude:35.681382 longitude:139.766084 distance:100.0 identifier:@"BRMLocation"];
```

You need to inherit BRMLocationReceiveDelegate to set delegation.

```objective-c
@interface MyClass : NSObject<BRMLocationReceiveDelegate>
```

Region monitoring delegates defined in BRMLocationReceiveDelegate,

```objective-c
- (void)didUpdateRegionEnter:(NSString *)identifier;
- (void)didUpdateRegionExit:(NSString *)identifier;
```

## Receive Eddystone region monitoring and ranging.

```objective-c
BRMEddystoneReceiveManager *eddystoneReceiveManager = [BRMEddystoneReceiveManager sharedManager]
eddystoneReceiveManager.delegate = self;
```

You need to inherit BRMEddystoneReceiveDelegate to set delegation.

```objective-c
@interface MyClass : NSObject<BRMEddystoneReceiveDelegate>
```

Region monitoring delegates defined in BRMEddystoneReceiveDelegate,

```objective-c
- (void)didUpdateEnterUIDBeacon:(BRMEddystoneUIDBeacon *)brmUIDBeacon;
- (void)didUpdateEnterURLBeacon:(BRMEddystoneURLBeacon *)brmURLBeacon;
- (void)didUpdateEnterTLMBeacon:(BRMEddystoneTLMBeacon *)brmTLMBeacon;
- (void)didUpdateExitUIDBeacon:(BRMEddystoneUIDBeacon *)brmUIDBeacon;
- (void)didUpdateExitURLBeacon:(BRMEddystoneURLBeacon *)brmURLBeacon;
- (void)didUpdateExitTLMBeacon:(BRMEddystoneTLMBeacon *)brmTLMBeacon;
```

Ranging delegates defined in BRMEddystoneReceiveDelegate,

```objective-c
- (void)didRangeBeacons:(NSArray *)beacons;
```

You can get Eddystone beacon information from BRMEddystoneUIDBeacon, BRMEddystoneURLBeacon, BRMEddystoneTLMBeacon.

# License

Beacon Region Manager is released under the MIT license. See LICENSE for details.
