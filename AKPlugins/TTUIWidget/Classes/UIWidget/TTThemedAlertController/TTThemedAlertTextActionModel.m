//
//  TTThemedAlertTextActionModel.m
//  TTScrollViewController
//
//  Created by 冯靖君 on 15/4/12.
//  Copyright (c) 2015年 冯靖君. All rights reserved.
//

#import "TTThemedAlertTextActionModel.h"

@implementation TTThemedAlertTextActionModel

- (instancetype)initWithTextActionType:(TTThemedAlertTextActionType)actionType textFieldActionBlock:(TTThemedAlertTextFieldActionBlock)textFieldActionBlock textViewActionBlock:(TTThemedAlertTextViewActionBlock)textViewActionBlock withElementTag:(NSInteger)tag
{
    if (self = [super init]) {
        _actionType = actionType;
        _textElementTag = tag;
        if (actionType == TTThemedAlertTextActionTypeTextField) {
            _textFieldActionBlock = textFieldActionBlock;
        }
        else {
            _textViewActionBlock = textViewActionBlock;
        }
    }
    return self;
}

@end
