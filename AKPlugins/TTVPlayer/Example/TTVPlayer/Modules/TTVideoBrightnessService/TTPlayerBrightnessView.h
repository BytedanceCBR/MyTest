//
//  TTPlayerBrightnessView.h
//  Article
//
//  Created by 赵晶鑫 on 27/08/2017.
//
//

#import <UIKit/UIKit.h>

@interface TTPlayerBrightnessView : UIWindow

- (void)showWithCurrentBrightness:(CGFloat)currentBrightness newBrightness:(CGFloat)newBrightness;
- (void)dismissWithDuration:(CGFloat)duration completion:(void(^)())completion;

@end
