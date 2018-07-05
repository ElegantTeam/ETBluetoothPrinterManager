//
//  ETBeginPrintController.m
//  ETBluetoothPrinterManager_Example
//
//  Created by imac on 2018/7/4.
//  Copyright © 2018 volley. All rights reserved.
//

#import "ETBeginPrintController.h"
#import "ETBluetoothPrinterManager.h"

@interface ETBeginPrintController ()<ETBluetoothManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *printerNameLabel;

@property (nonatomic, strong) ETBluetoothPrinterManager *manager;

@end

@implementation ETBeginPrintController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.printerNameLabel.text = [NSString stringWithFormat:@"%@",self.peripherral.name];
    _manager = [ETBluetoothPrinterManager shareInstance];
    
}

- (void)didConnectPeripheral {
    //打印test
    NSMutableData *mutData = [NSMutableData data];
    NSString *print_text = @"testtesttesttesttesttest";
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *data = [print_text dataUsingEncoding:enc];
    [mutData appendData:data];
    
    Byte nextRowBytes[] = {0x0A};
    [mutData appendBytes:nextRowBytes length:sizeof(nextRowBytes)];
    
    [self.manager writePrintData:data];
}
- (void)writeValueSuccess {
    NSLog(@"写入数据成功");
}

- (void)didFailConnectPeripheral {
    NSLog(@"连接失败");
}

- (IBAction)printAction:(UIButton *)sender {
    if (!self.manager.isPowerOn) {
        NSLog(@"尚未开启蓝牙，请开启蓝牙");
    }
    
    [self.manager connectPeripheral:self.peripherral];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
