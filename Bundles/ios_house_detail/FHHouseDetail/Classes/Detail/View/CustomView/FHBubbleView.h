//
//  FHBubbleView.h
//  BubbleViewTest
//
//  Created by bytedance on 2020/8/25.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHBubbleView : UIView
- (instancetype)initWithTitle:(NSString *)titleName font:(UIFont *)font;
- (void)showWithsubView:(UIView *)subview toView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
