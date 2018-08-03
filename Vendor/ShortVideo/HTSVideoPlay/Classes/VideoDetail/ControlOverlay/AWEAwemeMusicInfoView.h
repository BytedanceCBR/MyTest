//
//  AWEAwemeMusicInfoView.h
//  Aweme
//
//  Created by willorfang on 16/10/9.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AWEAwemeMusicInfoView : UIView

@property (nonatomic, assign) BOOL hideLogo;
@property (nonatomic, assign) BOOL shadowDisabled;

- (void)configRollingAnimationWithLabelString:(NSString *)musicLabelString;

- (void)startAnimation;
- (void)stopAnimation;

@end
