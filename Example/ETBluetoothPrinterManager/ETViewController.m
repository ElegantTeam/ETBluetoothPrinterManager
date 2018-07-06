//
//  ETViewController.m
//  ETBluetoothPrinterManager
//
//  Created by volley on 06/28/2018.
//  Copyright (c) 2018 volley. All rights reserved.
//

#import "ETViewController.h"
#import "ETBluetoothPrinterManager.h"
#import "CBPeripheral+MacAddress.h"
#import "ETBeginPrintController.h"
#import "MBProgressHUD+ETTool.h"

@interface ETViewController ()<UITableViewDelegate, UITableViewDataSource, ETBluetoothManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *printBtn;

@property (nonatomic, strong) ETBluetoothPrinterManager *manager;
@property (nonatomic, strong) NSMutableArray *allPeripherals;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftItem;

@property (assign, nonatomic) ETPrintSettingType settingType; //当前设置的打印尺寸

@property (nonatomic, strong) NSMutableArray *linkedDevices;
@property (nonatomic, strong) NSMutableArray *no_linkedDevices;

@end

static NSString *cellIdentifier = @"systemCell";
@implementation ETViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.peripherals == nil) {
        self.settingType = ETPrintSettingType_80;
        self.manager = [ETBluetoothPrinterManager shareInstance];
//        [self.manager scanPeripherals];
    } else {
        self.navigationItem.leftBarButtonItems = @[];
        self.navigationItem.rightBarButtonItems = @[];
        self.allPeripherals = [NSMutableArray arrayWithArray:self.peripherals];
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.peripherals == nil) {
        self.manager.delegate = self;
        [self filterPeripherals];
    }
}

- (void)setSettingType:(ETPrintSettingType)settingType {
    _settingType = settingType;
    self.manager.filterPrefix = _settingType == ETPrintSettingType_80 ? @"Gprinter" : @"Jolimark-WelltouPrint";
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (self.peripherals == nil) {
        [self.manager stopScan];
        [self.manager disconnectPeripheral];
    }
}

#pragma mark - Filter
- (void)filterPeripherals {

    NSMutableArray *filters = [NSMutableArray array];

    //筛选需要的80mm或150mm的打印机
    for (CBPeripheral *peripheral in self.allPeripherals) {
        if (self.settingType == ETPrintSettingType_80 && ([peripheral.name hasPrefix:@"Gprinter"] || [peripheral.name hasPrefix:@"Qsprinter"])) {
            
                [filters addObject:peripheral];
            
        } else if (self.settingType == ETPrintSettingType_150 && ([peripheral.name hasPrefix:@"Jolimark"] || [peripheral.name hasPrefix:@"WelltouPrint"] || [peripheral.name hasPrefix:@"Bluetooth"])) {
            
                [filters addObject:peripheral];
        }
    }

    self.linkedDevices = [self.manager recentConnectedPeriplerals:filters];//已配对设备
    self.no_linkedDevices = [NSMutableArray arrayWithArray:filters];
    [self.no_linkedDevices removeObjectsInArray:self.linkedDevices];//未配对过的设备
    
    self.allPeripherals = [NSMutableArray arrayWithArray:filters];
    [self.tableView reloadData];
}

#pragma mark - ETBluetoothManagerDelegate
- (void)bluetoothStatusHasChange:(BOOL)isOn {
    [self.manager scanPeripherals];
}

- (void)didDiscoverPeripherals:(NSArray *)peripherals {
    
    self.allPeripherals = [NSMutableArray arrayWithArray:peripherals];

    [self filterPeripherals];
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

#pragma mark ACTION
- (IBAction)useRecentPerpheralPrint:(UIButton *)sender {
    if (!self.manager.isPowerOn) {
        [MBProgressHUD showText:@"请开启蓝牙"];
        NSLog(@"尚未开启蓝牙，请开启蓝牙");
    }
    
    if ([self.manager everConnected]) {
        [self.manager autoConnectEverPeripheral];
    } else {
        [MBProgressHUD showText:@"请先连接设备"];
        NSLog(@"运行过程中未连接过设备,请先连接设备。");
    }
}

- (IBAction)selectSizeAction:(UIBarButtonItem *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *size = @[@"80mm",@"150mm"];
    for (int i = 0; i < size.count; i++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:size[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.leftItem setTitle:size[i]];
            self.settingType = i == 0 ? ETPrintSettingType_80 : ETPrintSettingType_150;
            self.secTitle = size[i];
            [self.manager scanPeripherals];
        }];
        [alertController addAction:action];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)filterPeripheralAction:(UIBarButtonItem *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *size = @[@"已配对设备",@"未配对设备"];
    for (int i = 0; i < size.count; i++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:size[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self pushToDeviceVC:size[i] index:i];
        }];
        [alertController addAction:action];
    }
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)pushToDeviceVC:(NSString *)title index:(NSInteger)index {
    ETViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ETViewController"];
    vc.secTitle = title;
    vc.peripherals = index == 0 ? self.linkedDevices: self.no_linkedDevices;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allPeripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    CBPeripheral *peripherral = [self.allPeripherals objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",peripherral.name];
    cell.detailTextLabel.text = peripherral.mac_addr;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    CBPeripheral *peripherral = [self.allPeripherals objectAtIndex:indexPath.row];
    
    ETBeginPrintController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ETBeginPrintController"];
    vc.peripherral = peripherral;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.secTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (NSString *)secTitle {
    if (!_secTitle) {
        _secTitle = @"80mm设备";
    }
    return _secTitle;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
