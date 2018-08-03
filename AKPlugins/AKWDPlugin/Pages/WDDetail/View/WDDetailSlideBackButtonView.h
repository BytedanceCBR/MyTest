//
//  WDDetailSlideBackButtonView.h
//  Article
//
//  Created by wangqi.kaisa on 2017/6/22.
//
//

#import "SSViewBase.h"
#import "TTAlphaThemedButton.h"

/*
 * 6.22 横向滑动切换回答的回答详情页左上角的返回按钮，封装出来方便控制
 *      日间分两种，夜间是一种，丑！
 *      iPad也是只有一种
 */

typedef NS_ENUM(NSInteger, WDDetailBackButtonStyle){
    WDDetailBackButtonStyleDefault          = 0, // 黑色
    WDDetailBackButtonStyleLightContent     = 1, // 白色
} ;

@interface WDDetailSlideBackButtonView : SSViewBase

@property(nonatomic, assign) WDDetailBackButtonStyle style;
@property(nonatomic, strong, readonly) TTAlphaThemedButton *backButton;

@end

extern CGRect WDDetailSlideBackButtonFrame(void);
