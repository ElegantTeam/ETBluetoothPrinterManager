//
//  CBPeripheral+MacAddress.m
//  Inventory
//
//  Created by volley on 2018/5/14.
//  Copyright © 2018年 Elegant Team. All rights reserved.
//

#import "CBPeripheral+MacAddress.h"
#import <objc/runtime.h>

@implementation CBPeripheral (MacAddress)

- (void)setMac_addr:(NSString *)mac_addr {
    objc_setAssociatedObject(self, @selector(mac_addr), mac_addr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)mac_addr {
    return objc_getAssociatedObject(self, @selector(mac_addr));
}

@end
