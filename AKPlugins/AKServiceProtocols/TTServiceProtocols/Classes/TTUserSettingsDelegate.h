//
//  TTUserSettingsDelegate.h
//  Pods
//
//  Created by fengyadong on 2017/4/26.
//
//

#import <Foundation/Foundation.h>
#import "TTUserSettingsProvider.h"

@protocol TTUserSettingsDelegate <NSObject>

@optional
/**
 通知观察者用户设置的字体大小已经变化

 @param fontSize 用户设置的字体大小
 */
- (void)didChangeFontSize:(TTUserSettingsFontSize)fontSize;

@end
