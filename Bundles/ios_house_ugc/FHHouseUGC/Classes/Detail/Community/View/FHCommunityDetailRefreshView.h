//
//  TTForumRefreshView.h
//  TTUGCBusiness
//
//  Created by  wanghanfeng on 2019/1/24.
//

#import "SSThemed.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHCommunityDetailRefreshViewType) {
    FHCommunityDetailRefreshViewIdle,
    FHCommunityDetailRefreshViewPull, // 开始拉动时
    FHCommunityDetailRefreshViewLoading, // 加载时
    FHCommunityDetailRefreshViewWillRefresh // 将要开始刷新
};

@interface FHCommunityDetailRefreshView : UIView

@property(nonatomic, strong) UIColor *color;
@property(nonatomic, assign) CGFloat toShowMinDistance;
@property(nonatomic, assign) CGFloat toRefreshMinDistance;
@property(nonatomic, copy) NSString *loadingImageName;

- (void)setTitle:(NSString *)title forState:(FHCommunityDetailRefreshViewType)state;

- (void)updateWithContentOffsetY:(CGFloat)offsetY;

- (void)beginRefresh;

- (void)endRefresh;

@end

NS_ASSUME_NONNULL_END
