//
//  TTXiguaLiveLivingAnimationView.h
//  Article
//
//  Created by lipeilun on 2017/12/6.
//

#import <TTThemed/SSThemed.h>

typedef NS_ENUM(NSInteger, TTXiguaLiveLivingAnimationViewStyle) {
    TTXiguaLiveLivingAnimationViewStyleLargeAndLine,                //大号+有竖线
    TTXiguaLiveLivingAnimationViewStyleMiddleAndLine,               //中号+有竖线
    TTXiguaLiveLivingAnimationViewStyleSmallNoLine,                 //小号+无竖线
};

@interface TTXiguaLiveLivingAnimationView : SSThemedView

- (instancetype)initWithStyle:(TTXiguaLiveLivingAnimationViewStyle)style;

- (void)beginAnimation;
- (void)stopAnimation;

@end
