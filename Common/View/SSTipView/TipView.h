//
//  TipView.h
//  Essay
//
//  Created by Tianhang Yu on 12-5-8.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 可以讨论是否要整合到 SSSimpleIndicator 中
 */

@interface TipView : UIView

- (id)initWithFrame:(CGRect)frame image:(NSString *)imageName message:(NSString *)message;
- (void)setHideTarget:(id)target selector:(SEL)selector;
@property(nonatomic, retain)NSString *message;
@property(nonatomic, retain)UIImage *image;
@property (nonatomic, retain) UIImageView *tipImage;
@property (nonatomic, retain) UILabel     *tipLabel;
@property (nonatomic, assign) BOOL autoLayout;
- (void)startWaitToDismiss:(float)secs;
- (void)invalidate;
@end
