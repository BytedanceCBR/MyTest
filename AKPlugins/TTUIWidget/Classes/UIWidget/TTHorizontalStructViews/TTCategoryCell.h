//
//  TTCategoryCell.h
//  TTUIWidget
//
//  Created by lizhuoli on 2018/3/22.
//

#import "SSThemed.h"
#import "TTCategoryItem.h"

@class TTBadgeNumberView;
/** 频道Cell */
@interface TTCategoryCell : UICollectionViewCell

/** 标题栏 */
@property (nonatomic, strong) SSThemedLabel * _Nonnull titleLabel;
/** 高亮标题栏 */
@property (nonatomic, strong) SSThemedLabel * _Nonnull maskLabel;
/** 右侧分割线 */
@property (nonatomic, strong) SSThemedView * _Nonnull rightLine;
/** 红点 */
@property (nonatomic, strong) TTBadgeNumberView * _Nonnull badgeView;
/** 频道项 */
@property (nonatomic, strong) TTCategoryItem *  _Nonnull cellItem;
/** 启用高亮显示 */
@property (nonatomic) BOOL enableHighlightedStatus;
/** 启用高亮动画 */
@property (nonatomic) BOOL animatedHighlighted;
/** 启用高亮变大动画 */
@property (nonatomic) BOOL animatedBiggerState;

#pragma mark UI setting
- (void)setTabBarTextColor:(nullable UIColor *)textColor maskColor:(nullable UIColor *)maskColor lineColor:(nullable UIColor *)lineColor;

- (void)setTabBarTextColorThemeKey:(nullable NSString *)textColorKey maskColorThemeKey:(nullable NSString *)maskColorKey lineColorThemeKey:(nullable NSString *)lineColorKey;

- (void)setTabBarTextFont:(nullable UIFont *)font;

- (void)setTabBarTextFont:(nullable UIFont *)textFont maskTextFont:(nullable UIFont *)maskFont;

- (void)setBadgeViewOffset:(UIOffset)offset;

- (void)setTitleLabelOffset:(UIOffset)offset;

@end
