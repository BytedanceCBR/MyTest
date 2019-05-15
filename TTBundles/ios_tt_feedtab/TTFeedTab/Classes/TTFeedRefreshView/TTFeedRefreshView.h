//
//  TTFeedRefreshView.h
//  Article
//
//  Created by matrixzk on 15/9/2.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

@interface TTFeedRefreshView : UIView

@property (nonatomic, strong, readonly) SSThemedButton *arrowBtn;
@property (nonatomic, assign, readonly) CGFloat        originAlpha;

- (void)startLoading;
- (void)endLoading;

- (void)resetFrameWithSuperviewFrame:(CGRect)superViewFrame
                         bottomInset:(CGFloat)bottomInset;

@end
