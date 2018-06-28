//
//  ETBluetoothCentralManage.h
//  CoreBlueToothDemo
//
//  Created by volley on 2018/4/13.
//  Copyright © 2018年 Elegant Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol ETBluetoothManagerDelegate <NSObject>

@optional

- (void)didDiscoverPeripherals:(NSArray *)peripherals;

- (void)didConnectPeripheral;

- (void)writeValueSuccess;

- (void)bluetoothHasPowerOff;

- (void)didFailConnectPeripheral;

@end

@interface ETBluetoothPrinterManager : NSObject

@property (nonatomic, strong) CBPeripheral *peripheral;

@property (nonatomic, assign) BOOL isPowerOn;  // 蓝牙是否可用

@property (nonatomic, copy) NSString *filterPrefix;  // 过滤的打印机前缀

@property (nonatomic, weak) id<ETBluetoothManagerDelegate> delegate;

+ (instancetype)shareInstance;

- (void)scanPeripherals;
- (void)scanPeripheralsWithAlert:(BOOL)needAlert;//没开启蓝牙提示框需要弹出

- (void)connectPeripheral:(CBPeripheral *)peripheral;

- (BOOL)everConnected;
- (void)autoConnectEverPeripheral;

- (void)disconnectPeripheral;

- (void)stopScan;

- (void)writePrintData:(NSData *)data;

- (NSMutableArray *)recentConnectedPeriplerals:(NSArray *)peripherals;

@end
