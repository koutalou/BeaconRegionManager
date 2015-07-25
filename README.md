# Beacon Region Manager

Beacon Region Manager is wrapper for Region monitoring of geographical regions and beacon regions API, Sending iBeacon signal.

# Requirements

* You have added the .h/m files to your project.

* Add 'NSLocationAlwaysUsageDescription' into your project Info.plist

# Usage

```
#import "BRMBeacon.h"
```

include all of necessary classes.

BRMBeaconSendManger, BRMBeaconReceiveManager, BRMLocationReceivceManger will instanciate singleton after called sharedManager.

## Send iBeacon signal

```
[[BRMBeaconSendManager sharedManager] startBeaconWithUUID:@"2290B76D-300E-40C1-A40A-38D28477ADCB" identifier:@"BRMBeacon" major:100 minor:100 second:5.0];
```

## Receive iBeacon region monitoring and ranging.

```
BRMBeaconReceiveManager *beaconReceiveManager = [BRMBeaconReceiveManager sharedManager];
beaconReceiveManager.delegate = self;
beaconReceiveManager monitorBeaconRegionWithUuid:@"2290B76D-300E-40C1-A40A-38D28477ADCB" identifier:@"BRMBeacon"];
```

You can disable iBeacon ranging. (Default:enable)

```
beaconReceiveManager.allowRanging = NO;
```

You need to inherit BRMBeaconReceiveDelegate to set delegation.

```
@interface MyClass : NSObject<BRMBeaconReceiveDelegate>
```

Region monitoring delegates defined in BRMBeaconReceiveDelegate,

```
- (void)didUpdateRegionEnter:(NSString *)identifier;
- (void)didUpdateRegionExit:(NSString *)identifier;
```

Ranging delegates defined in BRMBeaconReceiveDelegate,

```
- (void)didRangeBeacons:(NSArray *)beacons identifier:(NSString *)identifier;
```

A device can not receive own iBeacon signal.

## Receive location region monitoring.

```
BRMLocationReceiveManager *locationReceiveManager = [BRMLocationReceiveManager sharedManager];
locationReceiveManager.delegate = self;
locationReceiveManager monitorLocationRegionWithLatitude:35.681382 longitude:139.766084 distance:100.0 identifier:@"BRMLocation"];
```

You need to inherit BRMLocationReceiveDelegate to set delegation.

```
@interface MyClass : NSObject<BRMLocationReceiveDelegate>
```

# License

Beacon Region Manager is released under the MIT license. See LICENSE for details.
