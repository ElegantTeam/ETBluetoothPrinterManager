//
//  ETViewController.h
//  ETBluetoothPrinterManager
//
//  Created by volley on 06/28/2018.
//  Copyright (c) 2018 volley. All rights reserved.
//

@import UIKit;

/*
 80mm 150mm， 要是还要其他尺寸要自己加。基本支持所有类型的打印机。
 */
typedef NS_ENUM(NSUInteger, ETPrintSettingType) {
    ETPrintSettingType_80 = 80,
    ETPrintSettingType_150 = 150,
};

@interface ETViewController : UIViewController

@property (nonatomic, copy) NSString *secTitle;

@property (nonatomic, strong) NSArray *peripherals;
@end
