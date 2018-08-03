//
//  TTRealnameAuthProgressView.h
//  Article
//
//  Created by lizhuoli on 16/12/18.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

@interface TTRealnameAuthProgressView : SSThemedView

typedef NS_ENUM(NSInteger, TTRealnameAuthProgressStep) {
    TTRealnameAuthProgressStart,
    TTRealnameAuthProgressID,
    TTRealnameAuthProgressFace,
    TTRealnameAuthProgressEnd
};

/** 设置实名认证状态条进度 */
- (void)setupViewWithStep:(TTRealnameAuthProgressStep)step;

@end
