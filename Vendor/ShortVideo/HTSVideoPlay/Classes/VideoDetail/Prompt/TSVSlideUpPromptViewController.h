//
//  TSVSlideUpPromptViewController.h
//  Pods
//
//  Created by 王双华 on 2017/9/7.
//
//

#import <UIKit/UIKit.h>
#import "AWEVideoDetailFirstUsePromptDefine.h"

///上滑效果 无效／弹出个人页／弹出评论页
typedef NS_ENUM(NSInteger, TSVDetailSlideUpViewType){
    TSVDetailSlideUpViewTypeNone,
    TSVDetailSlideUpViewTypeProfile,
    TSVDetailSlideUpViewTypeComment,
};

///点击头像 无效/跳转个人主页/弹出个人主页浮层
typedef NS_ENUM(NSInteger, TSVDetailAvatarClickType){
    TSVDetailAvatarClickTypeProfile,
    TSVDetailAvatarClickTypePrompt,
};

@interface TSVSlideUpPromptViewController : UIViewController

+ (void)showSlideUpPromotionIfNeededInViewController:(UIViewController *)containerViewController;

+ (BOOL)needSlideUpPromotion;
+ (void)setSlideUpPromotionShown;

+ (TSVDetailSlideUpViewType)slideUpViewType;

+ (TSVDetailAvatarClickType)clickAvatarType;

+ (void)increaseVideoPlayCountForProfileSlideUp;

@end
