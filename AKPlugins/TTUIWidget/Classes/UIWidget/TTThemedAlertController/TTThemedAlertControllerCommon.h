//
//  TTThemedAlertControllerCommon.h
//  TTScrollViewController
//
//  Created by 冯靖君 on 15/4/10.
//  Copyright (c) 2015年 冯靖君. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define IS_PHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

#define UIScreenWidth   (IS_PHONE ? [[UIScreen mainScreen] bounds].size.width : [UIApplication sharedApplication].keyWindow.bounds.size.width)
#define UIScreenHeight  (IS_PHONE ? [[UIScreen mainScreen] bounds].size.height : [UIApplication sharedApplication].keyWindow.bounds.size.height)

#define TTThemedAlertControllerAlertTypeTitleViewHeight 140
#define TTThemedAlertControllerSheetTypeTitleViewHeight 90
#define TTThemedAlertControllerCellHeight               44
#define TTThemedAlertTableViewMaxWidth                  270
//#define TTThemedAlertTableViewWidth                     (UIScreenWidth - 50 > TTThemedAlertTableViewMaxWidth ? TTThemedAlertTableViewMaxWidth : UIScreenWidth - 50)
#define TTThemedAlertTableViewWidth                     MIN(([UIApplication sharedApplication].keyWindow.bounds.size.width * 0.84), TTThemedAlertTableViewMaxWidth)
//#define TTThemedAlertTableViewWidthForPad               320.f
#define TTThemedActionSheetTableViewWidth               [UIApplication sharedApplication].keyWindow.bounds.size.width
#define TTThemedPopoverWidth                            300
#define TTThemedAlertControllerTextViewHeight           100
#define TTThemedAlertControllerTextElementMargin        20
#define TTThemedAlertControllerTextFieldHeight          30
#define TTThemedAlertControllerBottomMargin             27
#define TTThemedAlertControllerTitleSubTitleSpacing     2.5
#define TTThemedAlertControllerActionSheetMidMargin     4
#define TTThemedAlertControllerActionSheetEdgeMargin    10
#define TTThemedAlertControllerTextElementMidMargin     5

#define UIColorWithRGBA(r, g, b, a)    [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:(a) * 1.f]

#define TTThemedMajorColor  UIColorWithRGBA(255.0, 255.0, 255.0, 1)

#define TTThemedAlertControllerCellIdentifier       @"ttThemedAlertControllerCellIdentifier"

#define TTThemedAlertControllerTextFieldActionKey   @"textFieldActionKey"

//#define TTThemed

typedef NS_ENUM(NSInteger, TTThemedAlertControllerType)
{
    TTThemedAlertControllerTypeAlert,
    TTThemedAlertControllerTypeActionSheet
};

typedef NS_ENUM(NSInteger, TTThemedAlertActionType)
{
    TTThemedAlertActionTypeCancel,
    TTThemedAlertActionTypeNormal,
    TTThemedAlertActionTypeDestructive
};

typedef void (^TTThemedAlertActionBlock)();
typedef void (^TTThemedAlertTextFieldActionBlock)(UITextField *textField);
typedef void (^TTThemedAlertTextViewActionBlock)(UITextView *textView);

@interface TTThemedAlertControllerCommon : NSObject

+ (CGFloat)ttthemedAlertControllerCellCornerRadius;

@end
