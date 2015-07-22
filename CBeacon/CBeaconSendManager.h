//
//  CBeaconSendManager.h
//  
//
//  Created by koutalou on 2015/07/18.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CBeaconSendManager : NSObject <CBPeripheralManagerDelegate>

+ (CBeaconSendManager *)sharedManager;

- (void)startBeaconWithUUID:(NSString *)uuid identifier:(NSString *)identifier major:(int)major minor:(int)minor second:(int)second;

@end
