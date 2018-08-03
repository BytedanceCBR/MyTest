//
//  TTThemedAlertActionElementModel.h
//  TTScrollViewController
//
//  Created by 冯靖君 on 15/4/10.
//  Copyright (c) 2015年 冯靖君. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTThemedAlertControllerCommon.h"

@interface TTThemedAlertActionElementModel : NSObject

@property (nonatomic, strong) UIColor *elementColor;
@property (nonatomic, strong) UIFont *elementFont;

+ (instancetype)elementModelWithAlertType:(TTThemedAlertControllerType)alertType actionType:(TTThemedAlertActionType)actionType;

@end
