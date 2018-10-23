//
//  WDWendaListCellUserHeaderView.h
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/12/27.
//

#import "SSThemed.h"

/*
 * 12.27 列表页cell顶部都是用户信息相关，单独封装成一个view，方便使用
 */

@class WDPersonModel;
@class TTFollowThemeButton;

@protocol WDWendaListCellUserHeaderViewDelegate <NSObject>

- (void)listCellUserHeaderViewAvatarClick;
- (void)listCellUserHeaderViewFollowButtonClick:(TTFollowThemeButton *)followBtn;

@end

@interface WDWendaListCellUserHeaderView : SSThemedView

+ (CGFloat)userHeaderHeight;

@property (nonatomic, strong, readonly) TTFollowThemeButton *followButton;

@property (nonatomic, weak) id<WDWendaListCellUserHeaderViewDelegate>delegate;

- (void)refreshUserInfoContent:(WDPersonModel *)user descInfo:(NSString *)descInfo followButtonHidden:(BOOL)hidden;

- (void)refreshDescInfoContent:(NSString *)descInfo;

- (void)refreshFollowButtonState:(BOOL)isFollowing;

- (void)setHighlighted:(BOOL)highlighted;

@end
