//
//  TTVFeedListVideoAdCell.m
//  Article
//
//  Created by panxiang on 2017/3/2.
//
//

#import "TTVFeedListVideoAdItem.h"
#import "TTVFeedListVideoTopContainerView.h"
#import "TTVFeedListAdBottomContainerView.h"
#import "TTVAdActionButtonCreation.h"
#import "TTVFeedCellForRowContext.h"
#import "SSADEventTracker.h"
#import "TTVFeedCellForRowContext.h"
#import "TTVFeedCellWillDisplayContext.h"
#import "TTVFeedCellSelectContext.h"
#import "TTVFeedCellEndDisplayContext.h"
#import "TTVFeedItem+Extension.h"
#import "TTUISettingHelper.h"
#import "TTVCellPlayMovie.h"
#import "TTVADEventTracker.h"

extern UIColor *tt_ttuisettingHelper_cellViewBackgroundColor(void);
extern UIColor *tt_ttuisettingHelper_cellViewHighlightedBackgroundColor(void);

@implementation TTVFeedListVideoAdCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _topContainerView = [[TTVFeedListVideoTopContainerView alloc] initWithFrame:CGRectZero];
        self.topMovieContainerView = _topContainerView.imageContainerView;
        [self.containerView addSubview:_topContainerView];
        @weakify(self);
        _topContainerView.imageContainerView.ttv_movieViewWillMoveToSuperViewBlock = ^(UIView *newView, BOOL animated) {
            @strongify(self);
            [self hiddenBottomAvatarViewIfNeed:newView animated:animated];
        };

        _bottomContainerView = [[TTVFeedListAdBottomContainerView alloc] initWithFrame:CGRectZero];
        [self.containerView addSubview:_bottomContainerView];
    }
    return self;
}

- (void)setItem:(TTVFeedListVideoAdItem *)item
{
    [super setItem:item];
    
    TTVFeedItem *feed = item.originData;
    TTVAdActionButton *adActionButton = getAdActionButtonInstance(feed.videoBusinessType);
    adActionButton.ttv_command.feedItem = item.originData;
    item.ttv_command = adActionButton.ttv_command;
    self.bottomContainerView.adActionButton = adActionButton;
    self.topContainerView.cellEntity = item;
    self.bottomContainerView.cellEntity = item;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    TTVFeedListVideoAdItem *item = (TTVFeedListVideoAdItem *)self.item;
    
    self.topContainerView.top = 0;
    self.topContainerView.width = self.containerView.width;
    
    self.topContainerView.height = self.containerView.height - adBottomContainerViewHeight();
    if (item.cellSeparatorStyle == TTVFeedListCellSeparatorStyleHas) {
        self.topContainerView.height = self.containerView.height - adBottomContainerViewHeight() - self.separatorLineView.height - self.bottomPaddingView.height;
    }
    self.bottomContainerView.top = self.topContainerView.bottom;
    self.bottomContainerView.width = self.containerView.width;
    self.bottomContainerView.height = adBottomContainerViewHeight();
    
    self.separatorLineView.top = self.bottomContainerView.bottom;
    self.bottomPaddingView.top = self.separatorLineView.bottom;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        self.backgroundColor = tt_ttuisettingHelper_cellViewHighlightedBackgroundColor();
    } else {
        self.backgroundColor = tt_ttuisettingHelper_cellViewBackgroundColor();
    }
    self.bottomContainerView.backgroundColor = self.backgroundColor;
    self.contentView.backgroundColor = self.backgroundColor;
}

- (void)willDisplayWithContext:(TTVFeedCellWillDisplayContext *)context
{
    [super willDisplayWithContext:context];    
}

- (void)endDisplayWithContext:(TTVFeedCellEndDisplayContext *)context
{
    [super endDisplayWithContext:context];
    [self.topContainerView.imageContainerView.playMovie didEndDisplaying];
}

// 首页列表cell点击处理
- (void)didSelectWithContext:(TTVFeedCellSelectContext *)context
{
    [super didSelectWithContext:context];
}

- (void)cellForRowContext:(TTVFeedCellForRowContext *)context
{
    [super cellForRowContext:context];
}

- (void)hiddenBottomAvatarViewIfNeed:(UIView *)supView animated:(BOOL)animated {
    if(ttvs_isVideoFeedCellHeightAjust() > 1){
        if (!supView) {                    //removeFromSuperView
            if ([ self.topContainerView.imageContainerView.playMovie currentMovieView].superview == self.topContainerView.imageContainerView.logo) {
                self.bottomContainerView.avatarView.hidden = NO;                 //从self.logo remove，所以显示
            }else{
                self.bottomContainerView.avatarView.hidden = YES;                //不是从self.logo remove ，则隐藏
            }
        }else {                            //willMoveToSuperView
            if (supView != self.topContainerView.imageContainerView.logo || !animated) {     //如果superview不是self.logo 则直接隐藏。
                self.bottomContainerView.avatarView.hidden = YES;
            }else{                                                              //superview是self.logo ,则动画隐藏
                [UIView animateWithDuration:.15
                                 animations:^{
                                     self.bottomContainerView.avatarView.alpha = 0;
                                 } completion:^(BOOL finished) {
                                     if ([ self.topContainerView.imageContainerView.playMovie currentMovieView].superview == self.topContainerView.imageContainerView.logo) {
                                         self.bottomContainerView.avatarView.hidden = YES;
                                     }
                                     self.bottomContainerView.avatarView.alpha = 1;
                                 }];
            }
        }
    }
}


@end

@implementation TTVFeedListVideoAdItem

- (CGFloat)cellHeightWithWidth:(NSInteger)width
{
    return [super cellHeightWithWidth:width] + [TTVFeedListVideoTopContainerView obtainHeightForFeed:self cellWidth:ttv_feedContainerWidth(width)];
}

@end
