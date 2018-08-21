//
//  TTThemedAlertActionModel.h
//  TTScrollViewController
//
//  Created by 冯靖君 on 15/4/10.
//  Copyright (c) 2015年 冯靖君. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTThemedAlertControllerCommon.h"
#import "TTThemedAlertActionElementModel.h"

@interface TTThemedAlertActionModel : NSObject

@property (nonatomic, copy) NSString *actionTitle;
@property (nonatomic, assign) TTThemedAlertActionType actionType;
@property (nonatomic, strong) TTThemedAlertActionBlock actionBlock;
@property (nonatomic, strong) TTThemedAlertActionElementModel *actionElementModel;

- (instancetype)initWithAlertType:(TTThemedAlertControllerType)alertType actionType:(TTThemedAlertActionType)actionType actionTitle:(NSString *)actionTitle actionBlock:(TTThemedAlertActionBlock)actionBlock;

@end
