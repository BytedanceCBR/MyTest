//
//  TTAnimatedRefreshView.h
//  Article
//
//  Created by 梁浩 on 2019/7/24.
//

#import "SSThemed.h"
#import <Lottie/LotComposition.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TTAnimatedRefreshStyle) {
    TTAnimatedRefreshStyleWideImage = 0, // 宽屏样式，支持图片/gif
    TTAnimatedRefreshStyleWideLottie     // 宽屏样式，支持lottie
};

@interface TTAnimatedRefreshView : SSThemedView

@property (nonatomic) TTAnimatedRefreshStyle imageStyle;
@property (nonatomic) CGFloat lottieThreshold;

- (BOOL)configureImageFilePath:(NSString *)imageFilePath lotComposition:(LOTComposition *)lotComposition width:(CGFloat)width height:(CGFloat)height;
- (void)updateAnimationWithScrollOffset:(CGFloat)offset;
- (void)startAnimation;
- (void)stopAnimation;

@end

NS_ASSUME_NONNULL_END
