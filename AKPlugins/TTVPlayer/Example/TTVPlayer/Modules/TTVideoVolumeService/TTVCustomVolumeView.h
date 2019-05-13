//
//  TTVCustomVolumeView.h
//  Article
//
//  Created by zhengjiacheng on 2018/8/31.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TTVCustomVolumeStyle) {
    TTVCustomVolumeStyleDefault,
    TTVCustomVolumeStyleLight,
};

@interface TTVCustomVolumeView : UIWindow

- (void)showWithStyle:(TTVCustomVolumeStyle)style
        currentVolume:(CGFloat)currentVolume
            newVolume:(CGFloat)newVolume;

- (void)dismissWithDuration:(CGFloat)duration completion:(void(^)())completion;

@end
