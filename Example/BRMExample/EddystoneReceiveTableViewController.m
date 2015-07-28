//
//  EddystoneReceiveTableViewController.m
//  BRMExample
//
//  Created by koutalou on 2015/07/28.
//  Copyright (c) 2015年 koutalou. All rights reserved.
//

#import "EddystoneReceiveTableViewController.h"

@interface EddystoneReceiveTableViewController ()

@end

@implementation EddystoneReceiveTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [BRMEddystoneReceiveManager sharedManager].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([BRMEddystoneReceiveManager sharedManager].monitoringEddystoneBeacons.count) {
        return 2;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return [BRMEddystoneReceiveManager sharedManager].monitoringEddystoneBeacons.count;
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
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 100.0f;
    }
    
    BRMEddystoneBeacon *eddystoneBeacon = [[BRMEddystoneReceiveManager sharedManager].monitoringEddystoneBeacons objectAtIndex:indexPath.row];
    if (eddystoneBeacon.frameType == kBRMEddystoneUIDFrameType) {
        return 100.0f;
    }
    else if (eddystoneBeacon.frameType == kBRMEddystoneURLFrameType) {
        return 80.f;
    }
    else {
        return 125.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell" forIndexPath:indexPath];
        return cell;
    }
    
    BRMEddystoneBeacon *eddystoneBeacon = [[BRMEddystoneReceiveManager sharedManager].monitoringEddystoneBeacons objectAtIndex:indexPath.row];
    
    switch (eddystoneBeacon.frameType) {
        case kBRMEddystoneUIDFrameType:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"eddystoneUIDCell" forIndexPath:indexPath];
            UILabel *rssiLabel = (UILabel *)[cell viewWithTag:1];
            UILabel *identifierLabel = (UILabel *)[cell viewWithTag:2];
            UILabel *namespaceIdLabel = (UILabel *)[cell viewWithTag:3];
            UILabel *instanceIdLabel = (UILabel *)[cell viewWithTag:4];
            
            BRMEddystoneUIDBeacon *eddystoneUIDBeacon = (BRMEddystoneUIDBeacon *)eddystoneBeacon;
            identifierLabel.text = eddystoneUIDBeacon.identifier;
            rssiLabel.text = [NSString stringWithFormat:@"%@",eddystoneUIDBeacon.averageRssi];
            namespaceIdLabel.text = eddystoneUIDBeacon.namespaceId;
            instanceIdLabel.text = eddystoneUIDBeacon.instanceId;
            
            break;
        }
        case kBRMEddystoneURLFrameType:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"eddystoneURLCell" forIndexPath:indexPath];
            UILabel *rssiLabel = (UILabel *)[cell viewWithTag:1];
            UILabel *identifierLabel = (UILabel *)[cell viewWithTag:2];
            UILabel *url = (UILabel *)[cell viewWithTag:3];
            
            BRMEddystoneURLBeacon *eddystoneURLBeacon = (BRMEddystoneURLBeacon *)eddystoneBeacon;
            identifierLabel.text = eddystoneURLBeacon.identifier;
            rssiLabel.text = [NSString stringWithFormat:@"%@",eddystoneURLBeacon.averageRssi];
            url.text = eddystoneURLBeacon.shortUrl;
            
            break;
        }
        case kBRMEddystoneTLMFrameType:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"eddystoneTLMCell" forIndexPath:indexPath];
            UILabel *rssiLabel = (UILabel *)[cell viewWithTag:1];
            UILabel *identifierLabel = (UILabel *)[cell viewWithTag:2];
            UILabel *versionLabel = (UILabel *)[cell viewWithTag:3];
            UILabel *vBattLabel = (UILabel *)[cell viewWithTag:4];
            UILabel *temperatureLabel = (UILabel *)[cell viewWithTag:5];
            UILabel *advCntLabel = (UILabel *)[cell viewWithTag:6];
            UILabel *secCntLabel = (UILabel *)[cell viewWithTag:7];
            
            BRMEddystoneTLMBeacon *eddystoneTLMBeacon = (BRMEddystoneTLMBeacon *)eddystoneBeacon;
            identifierLabel.text = eddystoneTLMBeacon.identifier;
            rssiLabel.text = [NSString stringWithFormat:@"%@",eddystoneTLMBeacon.averageRssi];
            versionLabel.text = [NSString stringWithFormat:@"%@",eddystoneTLMBeacon.version];
            vBattLabel.text = [NSString stringWithFormat:@"%@",eddystoneTLMBeacon.mvPerbit];
            temperatureLabel.text = [NSString stringWithFormat:@"%@",eddystoneTLMBeacon.temperature];
            advCntLabel.text = [NSString stringWithFormat:@"%@",eddystoneTLMBeacon.advertiseCount];
            secCntLabel.text = [NSString stringWithFormat:@"%@",eddystoneTLMBeacon.deciSecondsSinceBoot];
            
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - BRMEddystoneReceiveDelegate

- (void)didRangeBeacons:(NSArray *)beacons
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self.tableView reloadData];
}

- (void)didUpdateEnterUIDBeacon:(BRMEddystoneUIDBeacon *)brmUIDBeacon
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)didUpdateEnterURLBeacon:(BRMEddystoneURLBeacon *)brmURLBeacon
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}
- (void)didUpdateEnterTLMBeacon:(BRMEddystoneTLMBeacon *)brmTLMBeacon
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)didUpdateExitUIDBeacon:(BRMEddystoneUIDBeacon *)brmUIDBeacon
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)didUpdateExitURLBeacon:(BRMEddystoneURLBeacon *)brmURLBeacon
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

@end
