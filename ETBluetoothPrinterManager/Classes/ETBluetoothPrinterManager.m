//
//  ETBluetoothCentralManage.m
//  CoreBlueToothDemo
//
//  Created by volley on 2018/4/13.
//  Copyright © 2018年 Elegant Team. All rights reserved.
//

#import "ETBluetoothPrinterManager.h"
#import "MBProgressHUD+ETTool.h"
#import "CBPeripheral+MacAddress.h"

#define  kCachePath  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define  kLimitLength   146

@interface ETBluetoothPrinterManager ()<CBCentralManagerDelegate, CBPeripheralDelegate, UIAlertViewDelegate> {
    MBProgressHUD *_connectedHUD;
}

@property (nonatomic, strong) CBCentralManager *centralManager;

@property (nonatomic, strong) CBCharacteristic *characteristic;

@property (nonatomic, strong) CBCharacteristic *backupCharacteristic;

@property (nonatomic, strong) CBCharacteristic *notifyCharacteristic;

@property (nonatomic, strong) NSMutableArray *peripherals;  // 扫描到的设备

@property (nonatomic, strong) NSMutableDictionary *recentPeripherals; // 保存最新连接过的设备

@property (nonatomic, assign) BOOL isConnected;   // 是否是连接状态

@property (nonatomic, assign) BOOL flag;   // 是否找到特性标记位

@property (nonatomic, strong) NSTimer *connectTimer;    // 连接定时器

@property (nonatomic, assign) NSInteger writeValueTimes;   // 写入数据次数

@property (nonatomic, assign) NSInteger currentIndex;     /** 发送数据包序号 */

@property (nonatomic, strong) NSData *writeData;

@end

static ETBluetoothPrinterManager *manage = nil;

@implementation ETBluetoothPrinterManager

+ (instancetype)shareInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [[self alloc] init];
    });
    
    return manage;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _peripherals = [NSMutableArray array];
        _recentPeripherals = [NSMutableDictionary dictionary];
        NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey:@(NO)};
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
    }
    return self;
}


#pragma mark - 外部方法
- (void)scanPeripheralsWithAlert:(BOOL)needAlert {
    
    if (!self.isPowerOn) {
        [self openBluetoothAlert];
        return;
    }
    
    if (@available(iOS 9.0, *)) {
        if (self.centralManager.isScanning) {
            [self.centralManager stopScan];
        }
    }
    
    self.peripherals = [NSMutableArray array];
    
    if (self.peripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
        self.peripheral = nil;
    }
    
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)scanPeripherals {
    [self scanPeripheralsWithAlert:NO];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral {
    
    if (!self.isPowerOn) {
        [MBProgressHUD showText:@"请先打开蓝牙"];
        return;
    }
    
    if (!peripheral) {
        return;
    }
    
    _connectedHUD = [MBProgressHUD showPrintMessage:@"连接打印机..." toView:nil];

    self.flag = NO;
    NSDictionary *option = @{CBConnectPeripheralOptionNotifyOnDisconnectionKey : @(YES)};
    [self.centralManager connectPeripheral:peripheral options:option];
    
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(connectTimeOut) userInfo:nil repeats:NO];
}

- (void)disconnectPeripheral {

    if (self.peripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
        [self resetPeripheralStatus];
    }
}

- (void)stopScan {
    [self.centralManager stopScan];
}

- (void)writePrintData:(NSData *)data {
    
    self.writeData = data;
    
    if (!self.characteristic) {
        [_connectedHUD hideAnimated:NO];
        [MBProgressHUD showText:@"查找特性失败，无法打印"];
        return;
    }
    
    _connectedHUD.label.text = @"正在打印...";
    
    self.writeValueTimes = 1;
   
    if (data.length > kLimitLength) {
        NSInteger index = kLimitLength;
        for (; index < data.length - kLimitLength; index += kLimitLength) {
            self.writeValueTimes += 1;
        }
        
        NSData *leftData = [data subdataWithRange:NSMakeRange(index, data.length - index)];
        if (leftData.length > 0) {
            self.writeValueTimes += 1;
        }
    }
    
    self.currentIndex = 1;
    [self writeDataAtTimes:self.currentIndex];
}

- (void)writeDataAtTimes:(NSInteger)times {
    NSData *subData;
    NSInteger index = kLimitLength * (times - 1);
    if (times < self.writeValueTimes) {
        subData = [self.writeData subdataWithRange:NSMakeRange(index, kLimitLength)];
    }
    else {
        subData = [self.writeData subdataWithRange:NSMakeRange(index, self.writeData.length - index)];
    }
    [self.peripheral writeValue:subData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)connectTimeOut {
    
    [self invalidConnectedTimer];
    [_connectedHUD hideAnimated:NO];
    [MBProgressHUD showText:@"连接打印机失败"];
    
    if ([self.delegate respondsToSelector:@selector(didFailConnectPeripheral)]) {
        [self.delegate didFailConnectPeripheral];
    }
}

- (BOOL)everConnected {
    return [self.recentPeripherals objectForKey:self.filterPrefix] != nil;
}

- (void)autoConnectEverPeripheral {
    CBPeripheral *lastPeripheral = [self.recentPeripherals objectForKey:self.filterPrefix];
    [self connectPeripheral:lastPeripheral];
}

#pragma mark - helper method
- (NSMutableArray *)recentConnectedPeriplerals:(NSArray *)peripherals {
    
    NSString *filePath = [kCachePath stringByAppendingPathComponent:@"peripherals.plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    NSMutableArray *recent = [NSMutableArray array];
    for (CBPeripheral *peripheral in peripherals) {
        if ([dict.allKeys containsObject:peripheral.identifier.UUIDString]) {
            [recent addObject:peripheral];
        }
    }
    return recent;
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        self.isPowerOn = YES;
        [central scanForPeripheralsWithServices:nil options:nil];
    }
    else {
        [_connectedHUD hideAnimated:NO];
        
        self.isPowerOn = NO;
        if ([self.delegate respondsToSelector:@selector(bluetoothHasPowerOff)]) {
            [self.delegate bluetoothHasPowerOff];
        }
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {

    NSData *mac_data = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    if (mac_data) {
        peripheral.mac_addr = [self convertToMacAddressWithData:mac_data];
    }
    
    
    // 不可连接的过滤掉
    if (![advertisementData[CBAdvertisementDataIsConnectable] boolValue]) {
        return;
    }
    
    if (![[self peripheralNames] containsObject:peripheral.identifier.UUIDString]) {
        [self.peripherals addObject:peripheral];
        
        if ([self.delegate respondsToSelector:@selector(didDiscoverPeripherals:)]) {
            [self.delegate didDiscoverPeripherals:self.peripherals];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    [self invalidConnectedTimer];
    
    self.peripheral = peripheral;
    self.isConnected = YES;
    
    self.peripheral.delegate = self;
    
    [peripheral discoverServices:nil];
    
    [self writeConnectedPeripheral:peripheral];   // 将连接过的设备写在本地

    [self.recentPeripherals setObject:peripheral forKey:self.filterPrefix];   // 保存连接的设备
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    [self invalidConnectedTimer];
    
    [self resetPeripheralStatus];
    
    [MBProgressHUD showText:@"连接打印机失败，请稍后再试"];
    
    if ([self.delegate respondsToSelector:@selector(didFailConnectPeripheral)]) {
        [self.delegate didFailConnectPeripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    [self resetPeripheralStatus];
}

#pragma mark -  恢复到初始状态
- (void)resetPeripheralStatus {
    
    [_connectedHUD hideAnimated:NO];
    
    self.isConnected = NO;
    self.peripheral = nil;
    self.characteristic = nil;
    self.backupCharacteristic = nil;
}

- (void)invalidConnectedTimer {
    if (self.connectTimer) {
        [self.connectTimer invalidate];
        self.connectTimer = nil;
    }
}

#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error {
    
    for (CBCharacteristic * cha in service.characteristics)
    {
        CBCharacteristicProperties p = cha.properties;
       
        if (p & CBCharacteristicPropertyWriteWithoutResponse) {//无反馈写入特征
            self.backupCharacteristic = cha;
            
        }
        
        if (p & CBCharacteristicPropertyWrite) {//有反馈写入特征
            self.characteristic = cha;
        }
        
        if (p & CBCharacteristicPropertyNotify) {  // 通知特征
            self.notifyCharacteristic = cha;
            if (!cha.isNotifying) {
                [peripheral setNotifyValue:YES forCharacteristic:cha];
            }
        }
        
        if (p & CBCharacteristicPropertyRead) {  // 读特征
            
        }
        
    }
    
    // 找到有反馈写入特征和通知特征再回调
    if (self.characteristic && self.notifyCharacteristic) {
        if (!self.flag && [self.delegate respondsToSelector:@selector(didConnectPeripheral)]) {
            [self.delegate didConnectPeripheral];
            self.flag = YES;
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        [self disconnectPeripheral];
        [MBProgressHUD showText:@"打印失败，请重试"];
        return;
    }
    
    if (self.currentIndex >= self.writeValueTimes) {
        [self disconnectPeripheral];
        [MBProgressHUD showText:@"打印成功"];
        if ([self.delegate respondsToSelector:@selector(writeValueSuccess)]) {
            [self.delegate writeValueSuccess];
        }
        return;
    }
    
    self.currentIndex += 1;
    [self writeDataAtTimes:self.currentIndex];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
   
}

#pragma mark - private method
- (NSArray *)peripheralNames {
    
    NSMutableArray *names = [NSMutableArray array];
    for (CBPeripheral *peripheral in self.peripherals) {
        [names addObject:(peripheral.identifier.UUIDString ? : @"")];
    }
    return names;
}

- (void)writeConnectedPeripheral:(CBPeripheral *)peripheral {
    
    NSString *filePath = [kCachePath stringByAppendingPathComponent:@"peripherals.plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    
    if (dict == nil) {
        dict = [NSMutableDictionary dictionary];
    }
    
    NSString *key = peripheral.identifier.UUIDString;
    
    NSMutableArray *values = [NSMutableArray array];
    for (CBService *service in peripheral.services) {
        [values addObject:service.UUID.UUIDString];
    }
    
    [dict setValue:values forKey:key];
    
    [dict writeToFile:filePath atomically:YES];
}

- (void)openBluetoothAlert {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"尚未开启蓝牙，是否开启蓝牙"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"开启", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex) {
        NSURL *url = [NSURL URLWithString:@"App-Prefs:root=Bluetooth"];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
        }
    }
}

#pragma mark - getter
- (NSString *)filterPrefix {
    if (!_filterPrefix) {
        _filterPrefix = @"Gprinter";
    }
    return _filterPrefix;
}

#pragma mark - mac address
- (NSString *)convertToMacAddressWithData:(NSData *)data
{
    NSMutableArray *mac_addrs = [NSMutableArray array];
    
    const unsigned char *szBuffer = [data bytes];
    
    for (NSInteger i=0; i < [data length]; ++i) {
        
        NSString *str = [NSString stringWithFormat:@"%02lx",(unsigned long)szBuffer[i]];
        [mac_addrs addObject:str];
    }
    
    NSArray *sub_addrs = mac_addrs;
    if (mac_addrs.count > 6) {
        sub_addrs =  [mac_addrs subarrayWithRange:NSMakeRange(mac_addrs.count-6, 6)];
    }
    
    return [sub_addrs componentsJoinedByString:@":"];
}

@end
