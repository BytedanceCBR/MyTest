//
//  TTVFeedListLiveItem.m
//  Article
//
//  Created by panxiang on 2017/4/20.
//
//

#import "TTVFeedListLiveItem.h"
#import "TTVFeedListLiveTopContainerView.h"
#import "TTVFeedListLiveBottomContainerView.h"
#import "TTVFeedCellForRowContext.h"
#import "TTVFeedCellWillDisplayContext.h"
#import "TTVFeedCellSelectContext.h"
#import "TTVFeedCellEndDisplayContext.h"
#import "TTVCellPlayMovie.h"

@implementation TTVFeedListLiveItem

- (CGFloat)cellHeightWithWidth:(NSInteger)width
{
    return [super cellHeightWithWidth:width] + [TTVFeedListLiveTopContainerView obtainHeightForFeed:self cellWidth:ttv_feedContainerWidth(width)];
}

@end


@implementation TTVFeedListLiveCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _topContainerView = [[TTVFeedListLiveTopContainerView alloc] initWithFrame:CGRectZero];
//        self.topMovieContainerView = _topContainerView.imageContainerView;
        [self.containerView addSubview:_topContainerView];
        @weakify(self);
        _topContainerView.imageContainerView.ttv_movieViewWillMoveToSuperViewBlock = ^(UIView *newView, BOOL animated) {
            @strongify(self);
            [self hiddenBottomAvatarViewIfNeed:newView animated:animated];
        };

        _bottomContainerView = [[TTVFeedListLiveBottomContainerView alloc] initWithFrame:CGRectZero];
        [self.containerView addSubview:_bottomContainerView];
    }
    return self;
}

- (void)setItem:(TTVFeedListLiveItem *)item
{
    super.item = item;
    
    self.topContainerView.cellEntity = item;
    self.bottomContainerView.cellEntity = item;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    TTVFeedListLiveItem *item = (TTVFeedListLiveItem *)self.item;
    
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

- (void)endDisplayWithContext:(TTVFeedCellEndDisplayContext *)context
{
    [super endDisplayWithContext:context];
    [self.topContainerView.imageContainerView.playMovie didEndDisplaying];
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
