//
//  UIView+TTFFrame.h
//  TTFantasy
//
//  Created by 钟少奋 on 2017/11/30.
//

#import <UIKit/UIKit.h>

@interface UIView (TTFFrame)

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;

@property (nonatomic, assign) CGFloat ttf_centerX;
@property (nonatomic, assign) CGFloat ttf_centerY;

@end

@interface UIView (TTFHitTestExtensions)

@property (nonatomic, assign) UIEdgeInsets ttf_hitTestEdgeInsets;

@end

@interface UIView (TTFResponder)

- (UIViewController *)ttf_viewController;

@end
