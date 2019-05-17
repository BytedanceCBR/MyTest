//
//  TTVFullScreenBrightnessView.h
//  Article
//
//  Created by mazhaoxiang on 2018/11/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTVFullScreenBrightnessView : UIWindow

- (void)showWithCurrentBrightness:(CGFloat)currentBrightness newBrightness:(CGFloat)newBrightness;
- (void)dismissWithDuration:(CGFloat)duration completion:(void(^)())completion;

@end

NS_ASSUME_NONNULL_END
