//
//  TTThemedAlertControllerCommon.m
//  TTScrollViewController
//
//  Created by 冯靖君 on 15/4/10.
//  Copyright (c) 2015年 冯靖君. All rights reserved.
//

#import "TTThemedAlertControllerCommon.h"
#import "TTDeviceHelper.h"

@implementation TTThemedAlertControllerCommon

+ (CGFloat)ttthemedAlertControllerCellCornerRadius
{
    if ([TTDeviceHelper OSVersionNumber] < 9.0) {
        return 6.f;
    }
    else {
        return 13.f;
    }
}

@end
