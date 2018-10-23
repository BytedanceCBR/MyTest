//
//  WDDetailSlideMoreButtonView.h
//  Article
//
//  Created by wangqi.kaisa on 2017/6/22.
//
//

#import "SSViewBase.h"
#import "TTAlphaThemedButton.h"

/*
 * 6.22 横向滑动切换回答的回答详情页右上角的更多按钮，封装出来方便控制
 *      日间分两种，夜间是一种，丑！
 */

typedef NS_ENUM(NSInteger, WDDetailMoreButtonStyle){
    WDDetailMoreButtonStyleDefault          = 0, // 黑色
    WDDetailMoreButtonStyleLightContent     = 1, // 白色
} ;

@interface WDDetailSlideMoreButtonView : SSViewBase

@property(nonatomic, assign) WDDetailMoreButtonStyle style;
@property(nonatomic, strong, readonly)TTAlphaThemedButton *moreButton;

@end

extern CGRect WDDetailSlideMoreButtonFrame(void);
