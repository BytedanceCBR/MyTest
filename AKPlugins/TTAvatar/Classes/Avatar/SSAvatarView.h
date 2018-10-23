//
//  SSAvatarView.h
//  Article
//
//  Created by Zhang Leonardo on 12-12-24.
//
//

#import <UIKit/UIKit.h>

// TTThemed
#import "SSViewBase.h"

/**
 * SSAvatarView
 */

typedef enum SSAvatarViewStyle : NSUInteger { // 头像类型
    SSAvatarViewStyleRound, // 圆角头像
    SSAvatarViewStyleRectangle  // 矩形头像
}SSAvatarViewStyle;

@interface SSAvatarView : SSViewBase

/**
 头像类型
 */
@property(nonatomic, assign)SSAvatarViewStyle avatarStyle;

/*
 *  头像与背景图之间的间距
 *  头像的大小由 (self.frame.size.width / 2.f - backgroundImgPadding - avatarImgPadding)决定
 */
@property(nonatomic, assign)CGFloat avatarImgPadding;

/*
 *  控制背景图片与控件本身的margin
 *  为了如下需求,添加该参数:
 *  "点击区域不仅限于圆圈本身，需要时点击区域要可以比圆圈更大"
 *  默认为 UIEdgeInsetsZero
 */
@property(nonatomic, assign)UIEdgeInsets marginEdgeInsets;//default is UIEdgeInsetsZero

/*
 *  圆角矩形头像圆角值
 */
@property(nonatomic, assign)CGFloat rectangleAvatarImgRadius;

/*
 * 设置默认头像
 */
@property(nonatomic, strong)UIImage * defaultHeadImg;

/**
 设置默认背景图
 */
@property(nonatomic, strong)UIImage * backgroundNormalImage;

/**
 设置选中时背景图
 */
@property(nonatomic, strong)UIImage * backgroundHightlightImage;

//设置图片名字， 功能同defaultHeadImg， 如果需要两套图片支持的夜间模式， 需要调用该方法
@property(nonatomic, strong)NSString * defaultHeadImgName;

/**
 设置默认背景图名字， 功能同backgroundNormalImage， 如果需要两套图片支持的夜间模式， 需要调用该方法
 */
@property(nonatomic, strong)NSString * backgroundNormalImageName;

/**
 设置选中时背景图名字， 功能同backgroundHightlightImage， 如果需要两套图片支持的夜间模式， 需要调用该方法
 */
@property(nonatomic, strong)NSString * backgroundHightlightImageName;

//此处应该IPhoneDayModeThemeUISetting.strings 对应的key, 默认为白色
@property(nonatomic, strong)NSString * borderColorName;

/**
 响应点击事件的button
 */
@property(nonatomic, strong, readonly)UIButton * avatarButton;

/**
 夜间遮罩图
 */
@property(nonatomic, strong)UIImage * nightAvatarCoverImage;
/*
 *  头像（不包括背景）是否支持夜间模式
 *  默认为YES
 */
@property(nonatomic, assign)BOOL avatarSupportNightModel;

/**
  展示网络下载的头像

 @param urlStr 头像的URL
 */
- (void)showAvatarByURL:(NSString *)urlStr; 

/**
 设置本地头像

 @param avatarImg 头像图片
 */
- (void)setLocalAvatarImage:(UIImage *)avatarImg;

/**
  是否应该显示网络下载头像

 @return Yes/No
 */
- (BOOL)shouldShowImage;

/**
 网络下载头像是否已经缓存

 @return Yes/No
 */
- (BOOL)cached;

@end
