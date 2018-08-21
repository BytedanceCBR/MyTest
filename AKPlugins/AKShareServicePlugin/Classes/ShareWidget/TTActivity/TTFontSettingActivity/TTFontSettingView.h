//
//  TTFontSettingView.h
//  Article
//
//  Created by 延晋 张 on 2017/2/3.
//
//

#import "SSAlertViewBase.h"

typedef void(^TTFontViewDismissHandler)(void);

@interface TTFontSettingView : SSAlertViewBase

@property (nonatomic, copy) TTFontViewDismissHandler dismissHandler;

- (void)showOnController:(UIViewController *)controller;

@end
