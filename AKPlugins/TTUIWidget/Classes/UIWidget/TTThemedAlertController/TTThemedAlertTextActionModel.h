//
//  TTThemedAlertTextActionModel.h
//  TTScrollViewController
//
//  Created by 冯靖君 on 15/4/12.
//  Copyright (c) 2015年 冯靖君. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTThemedAlertControllerCommon.h"

typedef NS_ENUM(NSInteger, TTThemedAlertTextActionType)
{
    TTThemedAlertTextActionTypeTextView,
    TTThemedAlertTextActionTypeTextField
};

@interface TTThemedAlertTextActionModel : NSObject

@property (nonatomic, assign) TTThemedAlertTextActionType actionType;
@property (nonatomic, assign) NSInteger textElementTag;
@property (nonatomic, weak) TTThemedAlertTextFieldActionBlock textFieldActionBlock;
@property (nonatomic, weak) TTThemedAlertTextViewActionBlock textViewActionBlock;

- (instancetype)initWithTextActionType:(TTThemedAlertTextActionType)actionType textFieldActionBlock:(TTThemedAlertTextFieldActionBlock)textFieldActionBlock textViewActionBlock:(TTThemedAlertTextViewActionBlock)textViewActionBlock withElementTag:(NSInteger)tag;

@end
