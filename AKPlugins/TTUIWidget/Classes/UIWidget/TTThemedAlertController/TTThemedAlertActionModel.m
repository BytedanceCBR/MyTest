//
//  TTThemedAlertActionModel.m
//  TTScrollViewController
//
//  Created by 冯靖君 on 15/4/10.
//  Copyright (c) 2015年 冯靖君. All rights reserved.
//

#import "TTThemedAlertActionModel.h"

@implementation TTThemedAlertActionModel

- (instancetype)initWithAlertType:(TTThemedAlertControllerType)alertType actionType:(TTThemedAlertActionType)actionType actionTitle:(NSString *)actionTitle actionBlock:(TTThemedAlertActionBlock)actionBlock
{
    if (self = [super init]) {
        _actionType = actionType;
        _actionTitle = actionTitle;
        _actionBlock = actionBlock;
        _actionElementModel = [TTThemedAlertActionElementModel elementModelWithAlertType:alertType actionType:_actionType];
    }
    return self;
}

@end
