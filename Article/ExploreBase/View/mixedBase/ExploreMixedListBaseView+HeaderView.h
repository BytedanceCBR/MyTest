//
//  ExploreMixedListBaseView+HeaderView.h
//  Article
//
//  Created by Chen Hong on 16/5/27.
//
//

#import "ExploreMixedListBaseView.h"
#import "ExploreSearchView.h"
#import "ArticleCitySelectView.h"

@class TTSubEntranceBar;
@interface ExploreMixedListBaseView ()

@property(nonatomic, strong)ArticleCitySelectView *citySelectView;

@property(nonatomic, strong)UIPopoverController *padCitySelectPopover;

@property(nonatomic, strong)TTSubEntranceBar *subEntranceBar;

// 处理松手后bar自动显示/隐藏
@property(nonatomic, assign)BOOL isHeaderViewBarVisible;

@end


@interface ExploreMixedListBaseView (HeaderView)<UIPopoverControllerDelegate>

- (void)setListHeader:(UIView *)headerView;

- (BOOL)needShowCitySelectBar;

- (BOOL)needShowSubEntranceBar;

- (BOOL)needShowPGCBar;

- (void)updateCustomTopOffset;

- (void)refreshHeaderViewShowSearchBar:(BOOL)showSearchBar;

- (void)refreshSubEntranceBar;

- (void)citySelectViewClicked:(id)sender;

- (void)chooseCity:(NSNotification *)noti;

- (void)dismissCityPopoverAnimated:(BOOL)animated;

- (void)dockHeaderViewBar;

@end
