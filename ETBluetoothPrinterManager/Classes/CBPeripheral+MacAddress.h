//
//  CBPeripheral+MacAddress.h
//  Inventory
//
//  Created by volley on 2018/5/14.
//  Copyright © 2018年 Elegant Team. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (MacAddress)

@property (nonatomic, strong) NSString *mac_addr;

@end
