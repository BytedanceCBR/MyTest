//
//  TTVFullScreenVolumeView.h
//  Article
//
//  Created by mazhaoxiang on 2018/11/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTVFullScreenVolumeView : UIWindow

- (void)showWithCurrentVolume:(CGFloat)currentVolume newVolume:(CGFloat)newVolume;
- (void)dismissWithDuration:(CGFloat)duration completion:(void(^)())completion;

@end

NS_ASSUME_NONNULL_END
