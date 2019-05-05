//
//  TTSettingGeneralEntry.h
//  Article
//
//  Created by fengyadong on 16/11/2.
//
//

#import <Foundation/Foundation.h>
#import "TTImageInfosModel.h"

typedef NS_ENUM(NSUInteger, TTSettingHintStyle){
    TTSettingHintStyleNone = 0,
    TTSettingHintStyleRedPoint,
    TTSettingHintStyleNewFlag,
    TTSettingHintStyleNumber,
};
@interface TTSettingGeneralEntry : NSObject<NSCoding>

@property (nonatomic, copy)   NSString *key;//标示
@property (nonatomic, assign) BOOL     AKRequireLogin;//需要登录才能点击
@property (nonatomic, assign) BOOL     akTaskSwitch;//是否受任务开关的控制
@property (nonatomic, assign) BOOL shouldBeDisplayed;//是否应该展示
@property (nonatomic, assign) TTSettingHintStyle hintStyle;//飘新样式
@property (nonatomic, assign) long long hintCount;//飘新数字
@property (nonatomic, copy)   NSString *urlString;//跳转地址
@property (nonatomic, copy)   NSString *text;//文案
@property (nonatomic, copy)   NSString *accessoryText;//尾部tip
@property (nonatomic, copy)   NSString *accessoryTextColor;//尾部tip颜色
@property (nonatomic, copy)   void(^enter)(); // 入口，主要做跳转和统计
@property (nonatomic, copy)   BOOL(^update)(); // 刷新，有刷新逻辑的返回YES，所有更改属性的操作应放在update中。
@property (nonatomic, assign, getter=isModified) BOOL modified;
@property (nonatomic, assign) BOOL isTrackForShow;//有红点时，是否发show事件的埋点,记录是否发过show事件，发过后不再发
@property (nonatomic, assign) BOOL isTrackForMineTabShow;//我的tab上的红点是否发show事件的埋点，记录是否发过show事件，发过后不再发
// 清除红点数字
- (void)clearHint;

@end
