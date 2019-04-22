//
//  TSVRedPackPublishButton.h
//  Article
//
//  Created by xushuangqing on 05/12/2017.
//

#import <TTAlphaThemedButton.h>

typedef NS_ENUM(NSUInteger, TSVRedPackPublishButtonStyle) {
    TSVRedPackPublishButtonStyleNormal, //普通
    TSVRedPackPublishButtonStyleRed,
};

@interface TSVRedPackPublishButton : SSThemedButton

@property (nonatomic, assign) TSVRedPackPublishButtonStyle style;

- (void)startAnimation;

@end
