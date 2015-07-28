//
//  iBeaconReceiveTableViewController.m
//  BRMExample
//
//  Created by koutalou on 2015/07/26.
//  Copyright (c) 2015年 koutalou. All rights reserved.
//

#import "iBeaconReceiveTableViewController.h"

#define BRM_BEACON_UUID       @"2290B76D-300E-40C1-A40A-38D28477ADCB"
#define BRM_BEACON_IDENTIFIER @"BRM_RECEIVE_BEACON"

@interface iBeaconReceiveTableViewController ()

@end

@implementation iBeaconReceiveTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [BRMBeaconReceiveManager sharedManager].delegate = self;
    [[BRMBeaconReceiveManager sharedManager] monitorBeaconRegionWithUuid:BRM_BEACON_UUID identifier:BRM_BEACON_IDENTIFIER];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 + [BRMBeaconReceiveManager sharedManager].monitoringBeaconRegions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    BRMBeaconRegion *beaconRegion = [[BRMBeaconReceiveManager sharedManager].monitoringBeaconRegions objectAtIndex:section - 1];
    return beaconRegion.beacons.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.1f;
    } else {
        return 50.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"regionHeaderCell"];
    
    if (section == 0) {
        return cell;
    }
    
    BRMBeaconRegion *beaconRegion = [[BRMBeaconReceiveManager sharedManager].monitoringBeaconRegions objectAtIndex:section - 1];
    if (beaconRegion) {
        UILabel *identifierLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *UUIDLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *enterLabel = (UILabel *)[cell viewWithTag:3];

        identifierLabel.text = beaconRegion.identifier;
        UUIDLabel.text = beaconRegion.proximityUUID.UUIDString;

        if (beaconRegion.entered) {
            enterLabel.text = @"Inside";
        }
        else {
            enterLabel.text = @"Outside";
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 100.0f;
    }
    
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell" forIndexPath:indexPath];
        return cell;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"beaconInfoCell" forIndexPath:indexPath];
    
    BRMBeaconRegion *beaconRegion = [[BRMBeaconReceiveManager sharedManager].monitoringBeaconRegions objectAtIndex:indexPath.section - 1];
    
    CLBeacon *beacon = [beaconRegion.beacons objectAtIndex:indexPath.row];
    if (beacon) {
        UILabel *majorLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *minorLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *RSSILabel = (UILabel *)[cell viewWithTag:3];
        UILabel *proximityLabel = (UILabel *)[cell viewWithTag:4];
        majorLabel.text = [NSString stringWithFormat:@"%@", beacon.major];
        minorLabel.text = [NSString stringWithFormat:@"%@", beacon.minor];
        RSSILabel.text = [NSString stringWithFormat:@"%ld", (long)beacon.rssi];
        switch (beacon.proximity) {
            case CLProximityUnknown:
                proximityLabel.text = @"Unknown";
                break;
            case CLProximityImmediate:
                proximityLabel.text = @"Immediate";
                break;
            case CLProximityNear:
                proximityLabel.text = @"Near";
                break;
            case CLProximityFar:
                proximityLabel.text = @"Far";
                break;
        }
        
        if ((long)beacon.rssi == 0.0) {
            cell.backgroundColor = [UIColor grayColor];
        }
        else {
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
    
    return cell;
}

@end
