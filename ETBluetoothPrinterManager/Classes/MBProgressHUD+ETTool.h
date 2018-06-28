//
//  MBProgressHUD+ETTool.h
//
//
//  Created by Volley on 16/3/23.
//  Copyright © 2016年 Elegant Team. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (ETTool)

+ (MBProgressHUD *)showPrintMessage:(NSString *)message toView:(UIView *)view;

+ (void)showText:(NSString *)text;

+ (void)hideHUD;

@end
