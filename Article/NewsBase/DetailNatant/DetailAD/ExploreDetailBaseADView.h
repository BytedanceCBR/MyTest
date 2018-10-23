//
//  ExploreDetailBaseADView.h
//  Article
//
//  Created by SunJiangting on 15/7/21.
//
//

#import "ArticleDetailADModel.h"
#import "SSThemed.h"
#import "TTAdDetailViewUtil.h"
#import "TTAdDetailViewDefine.h"
#import "TTAdDetailViewModel.h"
#import "TTAlphaThemedButton.h"
#import "TTImageView.h"
#import <UIKit/UIKit.h>

#define kActionButtonWidth 72
#define kActionButtonHeight 28

#define kAdLabelHeight 14
#define kAdLabelWidth 26
#define kSourceLabelHeight 12

#define kVideoTitleBottomPadding 8
#define kVideoButtonRightPadding 8
#define kVideoButtonBottomPadding 8

#define kVideoTitleTopPadding 10
#define kVideoTitleBottomPadding 8
#define kVideoTitleLeftPadding 0
#define kVideoTitleRightPadding 0
#define kVideoTitleLabelFontSize 17.f

#define kVideoAppPhoneBottomHeight 48
#define kVideoAppPhoneBottomPadding 8
#define kVideoActionButtonPadding 10

#define kDetailAdTitleFontSize ceil([TTDeviceUIUtils tt_newFontSize:17])
#define kDetailAdTitleLineHeight ceil(kDetailAdTitleFontSize * 1.2)

#define kDetailAdSourceFontSize ceil([TTDeviceUIUtils tt_newFontSize:14])
#define kDetailAdSourceLineHeight ceil(kDetailAdSourceFontSize * 1.2)

#define kDetailAdLeftSourceFontSize ceil([TTDeviceUIUtils tt_newFontSize:12])
#define kDetailAdLeftSourceLineHeight ceil(kDetailAdLeftSourceFontSize * 1.2)

#define kDislikeMarginPadding 10

@class ExploreDetailBaseADView;


/**
 详情页 所有广告的基类
 建议 继承层级 不要不要超过 3层
 */
@interface ExploreDetailBaseADView : SSThemedView <TTAdDetailADView>

- (nullable instancetype)initWithWidth:(CGFloat)width;

/**
 数据模型
 */
@property (nullable, nonatomic, strong) ArticleDetailADModel *adModel;

/**
 容器
 */
@property (nullable, nonatomic, weak)   id<TTAdDetailADViewDelegate> delegate;
@property (nullable, nonatomic, strong) TTAlphaThemedButton *dislikeView;


/**
 容器 上下文环境
 */
@property (nullable, nonatomic, strong) TTAdDetailViewModel *viewModel;

+ (CGFloat)heightForADModel:(nonnull ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width;

- (void)didSendShowEvent;
- (void)didSendClickEvent;

/**
    触发 背景点击事件
 */
- (void)sendActionForTapEvent;

/**
 *  判断广告是否滑出页面
 *
 *  @param isVisible 广告是否在屏幕内
 */
- (void)scrollInOrOutBlock:(BOOL)isVisible;
- (void)sendAction:(nullable UIControl*)sender;

/**
 *  返回dislike按钮的图片
 *
 *  @return 图片名
 */
- (nullable NSString*)dislikeImageName;

@end

@interface ExploreDetailBaseADView (ExploreADLabel)

+ (void)updateADLabel:(nonnull SSThemedLabel *)adLabel withADModel:(nullable ArticleDetailADModel *)adModel;

@end


@interface ExploreDetailBaseADView (DetailCallAction)

- (void)callActionWithADModel:(nullable ArticleDetailADModel *)adModel;

@end

@interface ExploreDetailBaseADView (AppointFormAction)

- (void)appointActionWithADModel:(nullable ArticleDetailADModel *)adModel;

@end
