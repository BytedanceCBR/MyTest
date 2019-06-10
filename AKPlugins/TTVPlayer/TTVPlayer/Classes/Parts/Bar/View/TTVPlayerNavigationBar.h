//
//  TTVPlayerNavigationBar.h
//  TTVPlayer
//
//  Created by lisa on 2019/2/7.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerDefine.h"
#import "TTVTouchIgoringView.h"

NS_ASSUME_NONNULL_BEGIN


/**
 系统自带的navigationBar，有约束布局，高度修改困难；所以放弃系统自带的 bar，采用自定义 bar
 */
@interface TTVPlayerNavigationBar : TTVTouchIgoringView

- (UIView *)titleView;
- (UIView *)leftButton;
- (UIView *)rightView;

#pragma mark - UI
@property (nonatomic, strong) UILabel       *defaultTitleLable;    // 默认的标题 lable；plist 里面的设置，都是针对这个的设置
@property (nonatomic, strong) UIButton      *defaultBackButton;    // 默认的返回按钮；plist 里面的设置，都是针对这个的设置
@property (nonatomic, strong) UIImageView   *backgroundImageView;  // 背景图片

// custom view
@property (nonatomic, strong) UIView        *customTitleView;      // 如果设置了 customview，则在 plist 的自定义设置不起作用
@property (nonatomic, strong) UIButton      *customLeftButton;     // 如果设置了 customview，则在 plist 的自定义设置不起作用
@property (nonatomic, strong) UIView        *customRightView;

#pragma mark - set UI
// bar
@property (nonatomic) TTVPlayerLayoutVerticalAlign verticalAlign;   // 垂直对齐， 默认是顶对齐



@end

NS_ASSUME_NONNULL_END
