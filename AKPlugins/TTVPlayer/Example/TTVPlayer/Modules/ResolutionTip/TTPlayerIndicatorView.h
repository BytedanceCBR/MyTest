//
//  TTPlayerIndicatorView.h
//  Article
//
//  Created by 赵晶鑫 on 31/03/2017.
//
//

#import <UIKit/UIKit.h>
#import <TTVideoEngineModelDef.h>

typedef NS_ENUM(NSUInteger, TTPlayerResolutionSwitchState) {
    /**
     *  切换开始
     */
    TTPlayerResolutionSwitchStateStart = 0,
    /**
     *  切换成功
     */
    TTPlayerResolutionSwitchStateDone = 1,
    /**
     *  切换失败
     */
    TTPlayerResolutionSwitchStateFailed = 2,
};

@interface TTPlayerIndicatorView : UIView

// 切换清晰度
- (void)switchResolutionWithType:(TTVideoEngineResolutionType)resolution state:(TTPlayerResolutionSwitchState)state;

// 切换倍速
- (void)switchPlaybackSpeedWithTip:(NSString *)tip;

// 立即隐藏
- (void)hide;

@end
