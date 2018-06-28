//
//  MBProgressHUD+ETTool.m
//
//
//  Created by Volley on 16/3/23.
//  Copyright © 2016年 Elegant Team. All rights reserved.
//

#import "MBProgressHUD+ETTool.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(rgbValue,A) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:A]

@implementation MBProgressHUD (ETTool)

+ (void)showText:(NSString *)text
{
    [self showWithText:text view:nil];
}

+ (void)showWithText:(NSString *)text view:(UIView *)view
{
    [self showWithText:text view:view offset:0];
}

+ (void)showWithText:(NSString *)text view:(UIView *)view offset:(CGFloat)offset
{
    if (view == nil) view = [UIApplication sharedApplication].delegate.window;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabel.text = text;
    hud.contentColor = UIColorFromRGB(0xffffff);
    hud.margin = 20.f;
   
    hud.bezelView.color = UIColorFromRGBA(0x000000, 0.67);
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.detailsLabel.font = [UIFont systemFontOfSize:15];
    hud.removeFromSuperViewOnHide = YES;
    
    //向下偏移
    hud.offset = CGPointMake(0, offset);
    
    [hud hideAnimated:YES afterDelay:1.2];
}

+ (MBProgressHUD *)showPrintMessage:(NSString *)message toView:(UIView *)view {
    
    if (view == nil) view = [UIApplication sharedApplication].delegate.window;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.margin = 20.f;
    hud.label.text = message;
    hud.contentColor = UIColorFromRGB(0xffffff);
    hud.bezelView.color = UIColorFromRGBA(0x000000, 0.67);
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.label.font = [UIFont systemFontOfSize:15];
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    return hud;
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}

+ (void)hideHUDForView:(UIView *)view
{
     if (view == nil) view = [UIApplication sharedApplication].delegate.window;
     [self hideHUDForView:view animated:YES];
}

@end

