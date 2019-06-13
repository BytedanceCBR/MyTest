//
//  ExploreDetailToolbarView.h
//  Article
//
//  Created by SunJiangting on 15/7/27.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTAlphaThemedButton.h"
#import "TTArticleDetailDefine.h"

typedef NS_ENUM(NSInteger, FHExploreDetailToolbarType) {
    FHExploreDetailToolbarTypeNormal,
    FHExploreDetailToolbarTypeOnlyWriteButton,
    FHExploreDetailToolbarTypeExcludeCommentButtons,
    FHExploreDetailToolbarTypeExcludeCollectButton,
    FHExploreDetailToolbarTypeArticleComment,
    FHExploreDetailToolbarTypePhotoComment,
    FHExploreDetailToolbarTypePhotoOnlyWriteButton,
    FHExploreDetailToolbarTypeCommentDetail
};

typedef NS_ENUM(NSUInteger, FHExploreDetailToolbarFromView) {
    FHExploreDetailToolbarFromViewUnknown,
    FHExploreDetailToolbarFromViewVideoDetail
};

NS_ASSUME_NONNULL_BEGIN
@interface FHExploreDetailToolbarView : SSThemedView

@property (nonatomic, strong, readonly) TTAlphaThemedButton *writeButton;   // 写评论输入框
@property (nonatomic, strong, readonly) TTAlphaThemedButton *digButton;     // 点赞按钮
@property (nonatomic, strong) SSThemedLabel *digCountLabel;// 点赞数
@property (nonatomic, strong, readonly) SSThemedView *separatorView;

@property (nonatomic) TTDetailViewStyle viewStyle;

@property (nonatomic) FHExploreDetailToolbarType toolbarType;

@property (nonatomic) FHExploreDetailToolbarFromView fromView;

@property (nullable, nonatomic, copy) NSString *digCountValue;

@property (nonatomic, assign) BOOL banEmojiInput; // 是否支持表情输入

@end

extern CGFloat FHExploreDetailGetToolbarHeight(void);

NS_ASSUME_NONNULL_END
