//
//  TTUserInfoView.h
//  Article
//
//  Created by 冯靖君 on 15/12/29.
//
//

#import "SSViewBase.h"
#import "SSThemed.h"

@class TTAsyncLabel;

typedef void (^TitleLinkBlock)(NSString *title);
typedef void (^LogoLinkBlock)(NSString *linkURL);

typedef NS_ENUM(NSUInteger, TTOwnerType) {
    TTOwnerType_ContentAuthor = 1, //owner展示为作者
    TTOwnerType_CommentAuthor = 2, //owner展示为楼主
};

@interface TTUserInfoView : SSViewBase
/**
 *  定制标题字体
 */
@property(nonatomic, strong) TTAsyncLabel *titleLabel;
/**
 *  认证信息label
 */
@property(nonatomic, strong) SSThemedLabel *verifiedLabel;
/**
 *  定制文字颜色, 默认为字3
 */
@property(nonatomic, copy) NSString *textColorThemedKey;
/**
 *  定制Logo的placeholderImage
 */
@property(nonatomic, strong) UIImage *placeholderImage;
/**
 *  关闭Logo的夜间遮罩，默认会提供50%黑色透明遮罩
 */
@property(nonatomic, assign) BOOL disableLogoNightMask;
/**
 *  定制加V图标
 */
@property(nonatomic, copy) NSDictionary *verifiedLogoInfo;
/**
 *  定制楼主图标
 */
@property(nonatomic, copy) NSDictionary *ownerLogoInfo;
/**
 *  点击logo区域是否执行titleAction事件, 默认开
 */
@property(nonatomic, assign) BOOL titleClickActionExtendToLogos;

//是否显示作者／楼主
@property(nonatomic, assign) BOOL isBanShowAuthor;

@property (nonatomic, assign) TTOwnerType  ownerType;

/**
 *  指定构造器
 *
 *  @param baselineOriginPoint  下图中点B相对于父坐标系的位置, 一般把相邻UI控件的centerY作为y值传入即可
 如果init时无法确定传0，init后拿到height再设置top或centerY即可
 |---------------------------|
 |                           |
 B      TTUserInfoView       |
 |                           |
 |---------------------------|
 
 *  @param maxWidth             最大宽度
 *  @param limitHeight          限高，没有或不确定时传0, 当前处理是直接扔掉。对titleLabel无效
 *  @param title                标题或用户名
 *  @param fontSize             字体
 *  @param logoArray            添加的logo数组，元素为字典信息
 *
 *  @return 实例
 */
- (instancetype)initWithBaselineOrigin:(CGPoint)baselineOriginPoint
                              maxWidth:(CGFloat)maxWidth
                           limitHeight:(CGFloat)limitHeight
                                 title:(NSString *)title
                              fontSize:(CGFloat)fontSize
                   appendLogoInfoArray:(NSArray<NSDictionary *>*)logoArray DEPRECATED_ATTRIBUTE;

/*
 *
 *  @param maxWidth             最大宽度
 *  @param limitHeight          限高，没有或不确定时传0, 当前处理是直接扔掉。对titleLabel无效
 *  @param title                标题或用户名
 *  @param verifiedInfo         认证信息 nullable
 *  @param font                 title字体
 *  @param logoArray            添加的logo数组，元素为字典信息
 *
 *  @return 实例
 */
- (instancetype)initWithBaselineOrigin:(CGPoint)baselineOriginPoint
                              maxWidth:(CGFloat)maxWidth
                           limitHeight:(CGFloat)limitHeight
                                 title:(NSString *)title
                              fontSize:(CGFloat)fontSize
                          verifiedInfo:(NSString *)verifiedInfo
                   appendLogoInfoArray:(NSArray<NSDictionary *> *)logoArray;

/*
 *
 *  @param maxWidth             最大宽度
 *  @param limitHeight          限高，没有或不确定时传0, 当前处理是直接扔掉。对titleLabel无效
 *  @param title                标题或用户名
 *  @param verifiedInfo         认证信息 nullable
 *  @param font                 title字体
 *  @param isVerified           是否加V
 *  @param isOwener             是否楼主
 *  @param logoArray            添加的logo数组，元素为字典信息
 *
 *  @return
 */
- (instancetype)initWithBaselineOrigin:(CGPoint)baselineOriginPoint
                              maxWidth:(CGFloat)maxWidth
                           limitHeight:(CGFloat)limitHeight
                                 title:(NSString *)title
                              fontSize:(CGFloat)fontSize
                          verifiedInfo:(NSString *)verifiedInfo
                              verified:(BOOL)isVerified
                                 owner:(BOOL)isOwner
                   appendLogoInfoArray:(NSArray<NSDictionary *> *)logoArray NS_DESIGNATED_INITIALIZER;

/**
 *  数据更新后刷新控件，用于cell复用
 *  (暂只支持每个cell允许的maxWidth一致的情况)
 *
 *  @deprecated 废弃，请使用refreshWithTitle:(NSString *)title verifedInfo:(NSString *)verifedInfo appendLogoInfoArray:(NSArray<NSDictionary *> *)logoArray
 */
- (void)refreshWithTitle:(NSString *)title appendLogoInfoArray:(NSArray<NSDictionary *>*)logoArray DEPRECATED_ATTRIBUTE;

- (void)refreshWithTitle:(NSString *)title verifedInfo:(NSString *)verifedInfo appendLogoInfoArray:(NSArray<NSDictionary *> *)logoArray;

/**
 *
 * @param title         标题
 * @param relation      关系 例如已关注 ,好友
 * @param isVerified    是否加V
 * @param isOwner       是否楼主
 * @param logoArray     服务端下发的动态logo
 */
- (void)refreshWithTitle:(NSString *)title relation:(NSString *)relation verifiedInfo:(NSString *)verifiedInfo verified:(BOOL)isVerified owner:(BOOL)isOwner maxWidth:(CGFloat)maxWidth appendLogoInfoArray:(NSArray<NSDictionary *> *)logoArray;
/**
 *  title点击事件
 */
- (void)clickTitleWithAction:(TitleLinkBlock)block;

/**
 *  logo点击事件
 */
- (void)clickLogoWithAction:(LogoLinkBlock)block;

@end
