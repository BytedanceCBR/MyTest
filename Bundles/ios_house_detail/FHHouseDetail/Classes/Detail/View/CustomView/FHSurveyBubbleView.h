//
//  FHSurveyBubbleView.h
//  BubbleViewTest
//
//  Created by bytedance on 2020/8/25.
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MLLabel : UILabel
@end

@interface FHSurveyBubbleView : UIView
@property(nonatomic,assign) CGFloat arrowOffset;
@property(nonatomic,assign) UIEdgeInsets labelInsets;
@property(nonatomic,assign) CGFloat maxWidth;
- (instancetype)initWithTitle:(NSString *)titleName font:(UIFont *)font;
- (CGRect)calcFrameWithSubView:(UIView *)subview toView:(UIView *)view;
- (void)updateView;
@end

NS_ASSUME_NONNULL_END
