//
//  TTFollowThemeButton.h
//  Article
//
//  Created by chaisong on 2017/08/03.
//
//

#import "SSThemed.h"

/** 
 使用说明：
    本类为通用关注按钮控件(UI)，封装了关注按钮的所有样式及中间态，无任何业务代码
    支持随时更换类型，但这并不符合使用规范，请确认好您真正所需要的类型
 使用规范：
    初始化请统一调用initWithUnfollowedType:followedType:
    在buttonClick:方法中请先判断isLoading，如果为YES，则代表已经在进行关注/取消关注操作，应直接返回
    在开始进行关注/取消关注请求前，请调用startLoading方法
    在返回结果后，无论成功与否，都请将期望的关注状态设置给followed；如果isLoading，则会停止loading状态
    请在期望的关注状态需要更新时，更新followed
 */

/**
 关注按钮的UI规范
 https://wiki.bytedance.net/pages/viewpage.action?pageId=86367121
 
 101 对应重要、一般样式  只是宽度不同，宽度外部自行指定，默认58
 102 对应其它样式 默认宽度为文字 外部可以自行指定
 103 对应 较弱样式 有描边，宽度外部自行指定，默认58
 */

/** 未关注类型 */
typedef NS_ENUM(NSInteger, TTUnfollowedType) {
    /** 关注(蓝色背景 白色字 无描边) */
    TTUnfollowedType101          = 101,
    /** 关注(无色背景 蓝色字 无描边 粗体) */
    TTUnfollowedType102          = 102,
    /** 关注(无色背景 白色字 白色边) */
    TTUnfollowedType103          = 103,
    /** 关注(无色背景 粗体白色字 白色边) */
    TTUnfollowedType104          = 104,
    
    /** 🈴️关注(相对于101，关注前面加红包) */
    TTUnfollowedType201          = 201,
    /** 🈴️关注(相对于102，关注前面加红包) */
    TTUnfollowedType202          = 202,
    /** 🈴️关注(红包无icon，白字 红底) */
    TTUnfollowedType203          = 203,
    /** 🈴️关注(红包无icon，红字 透明底) */
    TTUnfollowedType204          = 204,
};

/** 已关注类型 */
typedef NS_ENUM(NSInteger, TTFollowedType) {
    /** 已关注(无色背景 灰色字 灰描边) */
    TTFollowedType101          = 101,
    /** 已关注(无色背景 灰色字 无描边) */
    TTFollowedType102          = 102,
    /** 已关注(无色背景 灰色字 灰描边 无autoresizingMask) */
    TTFollowedType103          = 103,
    /** 已关注(无色背景 灰色字 灰描边 浅色应用于关心主页) */
    TTFollowedType104          = 104,
    /** 已关注(无色背景 粗体灰色字 灰描边 无autoresizingMask) */
    TTFollowedType105          = 105,
};

/** 互相关注类型 */
typedef NS_ENUM(NSInteger, TTFollowedMutualType) {
    /** 互相关注(无，这种情况不出互相关注) */
    TTFollowedMutualTypeNone    = 0,
    
    /** 互相关注(无色背景 灰色字 灰描边) */
    TTFollowedMutualType101          = 101,
    /** 互相关注(无色背景 灰色字 无描边) */
    TTFollowedMutualType102          = 102,
    /** 互相关注(无色背景 灰色字 灰色边) */
    TTFollowedMutualType103          = 103,
    /** 互相关注(无色背景 粗体灰色字 灰色边) */
    TTFollowedMutualType104          = 104,
};

NS_INLINE CGFloat TTFollowButtonFloat(CGFloat input) {
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        return input * 1.3;
    }
    return input;
}

NS_INLINE CGFloat kDefaultFollowButtonHeight(){
    return TTFollowButtonFloat(28.f);
}

NS_INLINE CGFloat kDefaultFollowButtonWidth(){
    return TTFollowButtonFloat(58.f);
}

NS_INLINE CGFloat kRedPacketFollowButtonWidth(){
    return TTFollowButtonFloat(72.f);
}

/** 通用关注按钮 */
@interface TTFollowThemeButton : SSThemedButton

/** 未关注类型 */
@property (nonatomic, assign) TTUnfollowedType unfollowedType;
/** 已关注类型 */
@property (nonatomic, assign) TTFollowedType followedType;
/** 互相关注类型 */
@property (nonatomic, assign) TTFollowedMutualType followedMutualType;
/** 是否已关注 */
@property (nonatomic, assign) BOOL followed;
/** 是否已被关注 */
@property (nonatomic, assign) BOOL beFollowed;
/** 正在执行关注/取消关注操作 */
@property (nonatomic, assign, readonly, getter=isLoading) BOOL loading;

@property (nonatomic, assign) int constWidth; //如果该值不指定，则宽度为内部逻辑实现，101、103为58，102为自适应宽度
@property (nonatomic, assign) int constHeight; //如果该值不指定，则高度固定28

@property (nonatomic, assign) BOOL forbidNightMode;

/** 通过关注类型初始化 */
- (nonnull instancetype)initWithUnfollowedType:(TTUnfollowedType)unfollowedType followedType:(TTFollowedType)followedType;
- (nonnull instancetype)initWithUnfollowedType:(TTUnfollowedType)unfollowedType followedType:(TTFollowedType)followedType followedMutualType:(TTFollowedMutualType)followedMutualType;
/** 开始执行关注动画 */
- (void)startLoading;
/** 结束执行关注动画 */
- (void)stopLoading:(void(^ _Nullable)())finishLoading;
- (void)refreshUI;
+ (TTUnfollowedType)redpacketButtonUnfollowTypeButtonStyle:(NSInteger)style defaultType:(TTUnfollowedType)defaultType;
@end
