//
//  AKActivityTabManager.h
//  Article
//
//  Created by 冯靖君 on 2018/3/2.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AKActivityTabState)
{
    AKActivityTabStateInit,         // 初始态
    AKActivityTabStateCountDown,    // 倒计时态
    AKActivityTabStateBonus         // 有可领取宝箱
};

@interface AKActivityTabManager : NSObject

+ (instancetype)sharedManager;

// 更新底tab状态，启动及切换前后台时调用
- (void)startUpdateActivityTabState;

// 刷新活动tab
- (void)reloadActivityTabViewController;

// 隐藏/展示活动tab
- (void)updateActivityTabHiddenState:(BOOL)setToHidden;

@end

static inline NSString* numberOnWatch(NSInteger number)
{
    return number < 10 ? [NSString stringWithFormat:@"0%ld", number] : @(number).stringValue;
}
