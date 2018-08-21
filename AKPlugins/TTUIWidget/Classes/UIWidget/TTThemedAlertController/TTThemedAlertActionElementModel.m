//
//  TTThemedAlertActionElementModel.m
//  TTScrollViewController
//
//  Created by 冯靖君 on 15/4/10.
//  Copyright (c) 2015年 冯靖君. All rights reserved.
//

#import "TTThemedAlertActionElementModel.h"
#import "SSThemed.h"
#import "TTThemeConst.h"

@implementation TTThemedAlertActionElementModel

+ (instancetype)elementModelWithAlertType:(TTThemedAlertControllerType)alertType actionType:(TTThemedAlertActionType)actionType
{
    TTThemedAlertActionElementModel *model = [[self alloc] init];
    model.elementColor = SSGetThemedColorWithKey(kColorText200);
    model.elementFont = [self elementFontWithAlertType:alertType shouldBold:NO];
    /**
     *  目前禁用TTThemedAlertActionTypeDestructive样式（红色）的按钮
     */
//    if (actionType == TTThemedAlertActionTypeNormal || actionType == TTThemedAlertActionTypeCancel) {
//        model.elementColor = SSGetThemedColorWithKey(kColorText6);
//        model.elementFont = [self elementFontWithAlertType:alertType shouldBold:NO];
//    }
//    else {
//        model.elementColor = UIColorWithRGBA(255.0, 30.0, 29.0, 1);
//        model.elementFont = [self elementFontWithAlertType:alertType shouldBold:NO];
//    }
    
    return model;
}

+ (UIFont *)elementFontWithAlertType:(TTThemedAlertControllerType)alertType shouldBold:(BOOL)bold
{
    if (alertType == TTThemedAlertControllerTypeAlert) {
        return bold ? [UIFont boldSystemFontOfSize:17.0f] : [UIFont systemFontOfSize:17.0f];
    }
    else {
        return bold ? [UIFont boldSystemFontOfSize:18.0f] : [UIFont systemFontOfSize:20.0f];
    }
}

@end
